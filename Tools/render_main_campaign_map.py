#!/usr/bin/env python3

import argparse
import hashlib
import json
import math
import random
import sqlite3
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

from PIL import (
    Image,
    ImageChops,
    ImageDraw,
    ImageEnhance,
    ImageFilter,
    ImageFont,
    ImageOps,
)


BLUEPRINT_SIZE = (1536, 1024)
FINAL_SIZE = (3116, 2020)
KML_NAMESPACE = {"kml": "http://www.opengis.net/kml/2.2"}

# This viewport intentionally leaves a broad Atlantic margin for clustered
# callouts and enough western terrain to keep the coast from feeling cramped.
LON_MIN = -89.5
LON_MAX = -62.5
LAT_MIN = 29.8
LAT_MAX = 47.8
MAP_MARGIN = 34
BADGE_SCALE = 1.10
NUMBER_SCALE = 1.10 * 1.15
LABEL_SCALE = 1.10 * 1.10
DEFAULT_COLONIES_GEOJSON = (
    Path(__file__).parent / "data" / "american_colonies_1763_10m.geojson"
)
DEFAULT_DATABASE = Path(__file__).parent.parent / "Db" / "redcoat_raid.sqlite"
TITLE_OFFSET = (round((978 - 60) * 0.15), round((246 - 51) * 0.15))

FONT_DIR = Path("/System/Library/Fonts/Supplemental")
SERIF = FONT_DIR / "Georgia.ttf"
SERIF_BOLD = FONT_DIR / "Georgia Bold.ttf"
SERIF_ITALIC = FONT_DIR / "Georgia Italic.ttf"


@dataclass(frozen=True)
class PolygonGeometry:
    state_name: str
    outer: tuple[tuple[float, float], ...]
    holes: tuple[tuple[tuple[float, float], ...], ...]


@dataclass(frozen=True)
class CampaignStop:
    number: int
    name: str
    date_label: str
    latitude: float
    longitude: float
    badge_offset: tuple[int, int] = (0, 0)
    label_side: str = "right"


@dataclass(frozen=True)
class MapPalette:
    border_outer: tuple[int, int, int]
    border_inner: tuple[int, int, int]
    badge_outer: tuple[int, int, int]
    badge_outer_outline: tuple[int, int, int]
    badge_ring: tuple[int, int, int]
    badge_ring_outline: tuple[int, int, int]
    badge_center: tuple[int, int, int]
    badge_center_outline: tuple[int, int, int]
    ordinal: tuple[int, int, int]
    ordinal_outline: tuple[int, int, int]


PALETTES = {
    "burgundy-gold": MapPalette(
        border_outer=(75, 25, 30),
        border_inner=(255, 214, 92),
        badge_outer=(104, 61, 23),
        badge_outer_outline=(67, 38, 18),
        badge_ring=(237, 190, 51),
        badge_ring_outline=(255, 230, 131),
        badge_center=(177, 33, 39),
        badge_center_outline=(96, 17, 21),
        ordinal=(255, 249, 221),
        ordinal_outline=(84, 22, 20),
    ),
    "atlantic-blue": MapPalette(
        border_outer=(28, 65, 128),
        border_inner=(220, 241, 233),
        badge_outer=(28, 74, 64),
        badge_outer_outline=(12, 43, 39),
        badge_ring=(204, 174, 75),
        badge_ring_outline=(249, 231, 154),
        badge_center=(43, 112, 87),
        badge_center_outline=(16, 61, 50),
        ordinal=(255, 247, 207),
        ordinal_outline=(10, 48, 40),
    ),
}


# Geographic placement remains hand-authored, while sequence and dates are
# loaded from the database so campaign-roster edits automatically reach the map.
STOP_TEMPLATES = (
    CampaignStop(
        1,
        "Lexington & Concord",
        "APR 19, 1775",
        42.4512,
        -71.2922,
        (68, -62),
    ),
    CampaignStop(
        2,
        "Bunker Hill",
        "JUN 17, 1775",
        42.3763,
        -71.0608,
        (112, 4),
    ),
    CampaignStop(
        3,
        "Great Bridge",
        "DEC 9, 1775",
        36.7196,
        -76.2386,
        (18, -4),
    ),
    CampaignStop(
        4,
        "Moore's Creek Bridge",
        "FEB 27, 1776",
        34.4579,
        -78.1092,
        (24, -8),
    ),
    CampaignStop(
        5,
        "Dorchester Heights",
        "MAR 4, 1776",
        42.3329,
        -71.0465,
        (118, 79),
    ),
    CampaignStop(
        6,
        "Sullivan's Island",
        "JUN 28, 1776",
        32.7632,
        -79.8582,
        (99, -48),
    ),
    CampaignStop(
        7,
        "Long Island",
        "AUG 27, 1776",
        40.6602,
        -73.9690,
        (84, -17),
    ),
    CampaignStop(
        8,
        "Trenton",
        "DEC 26, 1776",
        40.2171,
        -74.7429,
        (66, 46),
    ),
    CampaignStop(
        9,
        "Princeton",
        "JAN 3, 1777",
        40.3315,
        -74.6752,
        (-53, 69),
        "left",
    ),
    CampaignStop(
        10,
        "Fort Ann",
        "JUL 8, 1777",
        43.4142,
        -73.4887,
        (-44, -35),
        "left",
    ),
    CampaignStop(
        11,
        "Saratoga",
        "SEP 19, 1777",
        42.9984,
        -73.6371,
        (14, 36),
        "left",
    ),
    CampaignStop(
        12,
        "Kettle Creek",
        "FEB 14, 1779",
        33.6862,
        -82.8860,
        (-14, -4),
        "left",
    ),
    CampaignStop(
        13,
        "New Haven",
        "JUL 5, 1779",
        41.3083,
        -72.9279,
        (89, -42),
        "top-left",
    ),
    CampaignStop(
        14,
        "Savannah",
        "SEP 16, 1779",
        32.0762,
        -81.0884,
        (-4, -33),
        "left",
    ),
    CampaignStop(
        15,
        "Charleston",
        "MAR 29, 1780",
        32.7765,
        -79.9311,
        (105, 43),
    ),
)


MONTH_LABELS = (
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
)


def database_name(display_name: str) -> str:
    return display_name.replace(" & ", " and ")


def date_label(iso_date: str) -> str:
    year, month, day = (int(value) for value in iso_date.split("-"))
    return f"{MONTH_LABELS[month - 1]} {day}, {year}"


def load_main_campaign_stops(database_path: Path) -> tuple[CampaignStop, ...]:
    templates = {
        database_name(template.name): template
        for template in STOP_TEMPLATES
    }
    with sqlite3.connect(database_path) as connection:
        rows = connection.execute(
            """
            SELECT
                level_info.level_name,
                strftime('%Y-%m-%d', level_info.started_at)
            FROM level_info
            JOIN campaign ON campaign.id = level_info.campaign_id
            WHERE campaign.campaign_name = 'Main'
              AND campaign.parent_campaign_id IS NULL
            ORDER BY level_info.started_at, level_info.id
            """
        ).fetchall()

    if len(rows) != 15:
        raise ValueError(
            f"Expected 15 Main campaign levels in {database_path}, found {len(rows)}"
        )

    missing = [level_name for level_name, _date in rows if level_name not in templates]
    if missing:
        raise ValueError(
            "Missing geographic placement for Main campaign level(s): "
            + ", ".join(missing)
        )

    stops = []
    for number, (level_name, started_on) in enumerate(rows, start=1):
        template = templates[level_name]
        stops.append(
            CampaignStop(
                number=number,
                name=template.name,
                date_label=date_label(started_on),
                latitude=template.latitude,
                longitude=template.longitude,
                badge_offset=template.badge_offset,
                label_side=template.label_side,
            )
        )
    return tuple(stops)


REGION_LABELS = (
    ("CANADA", 46.65, -73.80),
    ("NEW ENGLAND", 43.80, -69.60),
    ("NEW YORK", 42.10, -76.00),
    ("PENNSYLVANIA", 40.70, -78.70),
    ("VIRGINIA", 37.70, -79.20),
    ("NORTH CAROLINA", 35.35, -80.60),
    ("SOUTH CAROLINA", 33.70, -80.90),
    ("GEORGIA", 32.65, -83.75),
    ("ILLINOIS COUNTRY", 40.15, -86.20),
)

# The source dataset represents the settled colonies around 1763, cropped by
# the National Park Service's Proclamation Line instead of later state claims.
COLONIES_1775 = (
    "New Hampshire",
    "Massachusetts",
    "Rhode Island",
    "Connecticut",
    "New York",
    "New Jersey",
    "Pennsylvania",
    "Delaware",
    "Maryland",
    "Virginia",
    "North Carolina",
    "South Carolina",
    "Georgia",
)

MAJOR_RIVERS = (
    (
        (-73.50, 44.20),
        (-73.62, 43.20),
        (-73.75, 42.45),
        (-73.80, 41.70),
        (-74.02, 40.70),
    ),
    (
        (-75.12, 42.05),
        (-75.20, 41.35),
        (-75.06, 40.70),
        (-75.22, 40.10),
        (-75.55, 39.45),
        (-75.42, 38.95),
    ),
    (
        (-76.90, 42.05),
        (-76.25, 41.15),
        (-76.50, 40.35),
        (-76.27, 39.75),
        (-76.10, 39.45),
    ),
    (
        (-79.50, 39.25),
        (-78.55, 39.05),
        (-77.70, 38.95),
        (-77.10, 38.75),
        (-76.45, 38.25),
    ),
    (
        (-80.05, 37.85),
        (-79.15, 37.55),
        (-78.25, 37.62),
        (-77.35, 37.35),
        (-76.65, 37.10),
    ),
    (
        (-86.45, 40.90),
        (-87.00, 40.10),
        (-87.30, 39.25),
        (-87.53, 38.68),
        (-87.75, 37.90),
    ),
    (
        (-80.55, 40.40),
        (-81.65, 39.45),
        (-83.10, 38.75),
        (-85.10, 38.05),
        (-87.75, 37.90),
    ),
    (
        (-79.10, 35.85),
        (-78.75, 35.15),
        (-78.25, 34.45),
        (-77.95, 34.05),
    ),
    (
        (-82.45, 34.85),
        (-82.08, 34.20),
        (-81.55, 33.45),
        (-81.10, 32.10),
    ),
)


APPALACHIAN_SPINE = (
    (34.45, -84.10),
    (35.30, -83.20),
    (36.10, -82.35),
    (37.05, -81.35),
    (38.00, -80.45),
    (39.00, -79.65),
    (40.05, -78.85),
    (41.10, -77.60),
    (42.10, -76.30),
    (43.15, -74.95),
)


STATE_PALETTE = (
    (185, 222, 129),
    (218, 210, 116),
    (148, 207, 143),
    (236, 190, 112),
    (136, 202, 173),
    (205, 224, 152),
    (230, 174, 125),
)


def project(
    longitude: float,
    latitude: float,
    size: tuple[int, int],
) -> tuple[float, float]:
    width, height = size
    usable_width = width - MAP_MARGIN * 2
    usable_height = height - MAP_MARGIN * 2
    x = MAP_MARGIN + (longitude - LON_MIN) / (LON_MAX - LON_MIN) * usable_width
    y = MAP_MARGIN + (LAT_MAX - latitude) / (LAT_MAX - LAT_MIN) * usable_height
    return x, y


def parse_coordinate_ring(value: str) -> tuple[tuple[float, float], ...]:
    points = []
    for coordinate in value.split():
        values = coordinate.split(",")
        if len(values) >= 2:
            points.append((float(values[0]), float(values[1])))
    return tuple(points)


def load_state_polygons(kml_path: Path) -> tuple[PolygonGeometry, ...]:
    tree = ET.parse(kml_path)
    geometries = []
    for placemark in tree.findall(".//kml:Placemark", KML_NAMESPACE):
        state_name = ""
        for simple_data in placemark.findall(".//kml:SimpleData", KML_NAMESPACE):
            if simple_data.attrib.get("name") == "NAME":
                state_name = (simple_data.text or "").strip()
                break

        for polygon in placemark.findall(".//kml:Polygon", KML_NAMESPACE):
            outer_element = polygon.find(
                "./kml:outerBoundaryIs/kml:LinearRing/kml:coordinates",
                KML_NAMESPACE,
            )
            if outer_element is None or not outer_element.text:
                continue

            holes = []
            for inner in polygon.findall(
                "./kml:innerBoundaryIs/kml:LinearRing/kml:coordinates",
                KML_NAMESPACE,
            ):
                if inner.text:
                    holes.append(parse_coordinate_ring(inner.text))

            geometries.append(
                PolygonGeometry(
                    state_name=state_name,
                    outer=parse_coordinate_ring(outer_element.text),
                    holes=tuple(holes),
                )
            )
    return tuple(geometries)


def load_colony_polygons(geojson_path: Path) -> tuple[PolygonGeometry, ...]:
    with geojson_path.open(encoding="utf-8") as source:
        collection = json.load(source)

    geometries = []
    for feature in collection.get("features", ()):
        colony_name = feature.get("properties", {}).get("NAME", "")
        geometry = feature.get("geometry") or {}
        geometry_type = geometry.get("type")
        coordinates = geometry.get("coordinates", ())
        if geometry_type == "Polygon":
            polygons = (coordinates,)
        elif geometry_type == "MultiPolygon":
            polygons = coordinates
        else:
            continue

        for polygon in polygons:
            if not polygon:
                continue
            outer = tuple(
                (float(point[0]), float(point[1]))
                for point in polygon[0]
            )
            holes = tuple(
                tuple(
                    (float(point[0]), float(point[1]))
                    for point in ring
                )
                for ring in polygon[1:]
            )
            geometries.append(
                PolygonGeometry(
                    state_name=colony_name,
                    outer=outer,
                    holes=holes,
                )
            )
    return tuple(geometries)


def projected_ring(
    coordinates: tuple[tuple[float, float], ...],
    size: tuple[int, int],
) -> list[tuple[int, int]]:
    result = []
    previous = None
    for longitude, latitude in coordinates:
        x, y = project(longitude, latitude, size)
        point = (round(x), round(y))
        if point != previous:
            result.append(point)
            previous = point
    return result


def color_for_state(state_name: str) -> tuple[int, int, int]:
    digest = hashlib.sha256(state_name.encode("utf-8")).digest()
    return STATE_PALETTE[digest[0] % len(STATE_PALETTE)]


def build_ocean(size: tuple[int, int]) -> Image.Image:
    width, height = size
    image = Image.new("RGB", size)
    pixels = image.load()
    for y in range(height):
        vertical = y / max(1, height - 1)
        for x in range(width):
            horizontal = x / max(1, width - 1)
            shimmer = 5 * math.sin(x * 0.015 + y * 0.009)
            pixels[x, y] = (
                round(72 - 16 * vertical + shimmer),
                round(183 - 35 * vertical + 7 * horizontal + shimmer),
                round(223 - 27 * vertical + 12 * horizontal + shimmer),
            )
    return image


def render_land(
    base: Image.Image,
    geometries: tuple[PolygonGeometry, ...],
) -> Image.Image:
    size = base.size
    land_mask = Image.new("L", size, 0)
    land_draw = ImageDraw.Draw(land_mask)

    for geometry in geometries:
        outer = projected_ring(geometry.outer, size)
        if len(outer) < 3:
            continue
        land_draw.polygon(outer, fill=255)
        for hole in geometry.holes:
            projected_hole = projected_ring(hole, size)
            if len(projected_hole) >= 3:
                land_draw.polygon(projected_hole, fill=0)

    shadow_mask = land_mask.filter(ImageFilter.GaussianBlur(max(3, size[0] // 350)))
    shadow = Image.new("RGBA", size, (30, 68, 59, 0))
    shadow.putalpha(shadow_mask.point(lambda value: round(value * 0.42)))
    shifted_shadow = Image.new("RGBA", size, (0, 0, 0, 0))
    shifted_shadow.alpha_composite(
        shadow,
        (max(3, size[0] // 320), max(4, size[1] // 230)),
    )
    composed = Image.alpha_composite(base.convert("RGBA"), shifted_shadow)

    for geometry in geometries:
        state_mask = Image.new("L", size, 0)
        state_draw = ImageDraw.Draw(state_mask)
        outer = projected_ring(geometry.outer, size)
        if len(outer) < 3:
            continue
        state_draw.polygon(outer, fill=255)
        for hole in geometry.holes:
            projected_hole = projected_ring(hole, size)
            if len(projected_hole) >= 3:
                state_draw.polygon(projected_hole, fill=0)

        fill_color = color_for_state(geometry.state_name)
        state_fill = Image.new("RGBA", size, (*fill_color, 255))
        composed = Image.composite(state_fill, composed, state_mask)

    grain = Image.new("RGBA", size, (0, 0, 0, 0))
    grain_draw = ImageDraw.Draw(grain)
    rng = random.Random(1775)
    for _ in range(round(size[0] * size[1] / 185)):
        x = rng.randrange(size[0])
        y = rng.randrange(size[1])
        radius = rng.choice((1, 1, 1, 2))
        color = (
            62,
            91,
            43,
            rng.randrange(10, 31),
        )
        grain_draw.ellipse(
            (x - radius, y - radius, x + radius, y + radius),
            fill=color,
        )
    grain.putalpha(Image.composite(grain.getchannel("A"), Image.new("L", size, 0), land_mask))
    composed = Image.alpha_composite(composed, grain)

    boundary_layer = Image.new("RGBA", size, (0, 0, 0, 0))
    boundary_draw = ImageDraw.Draw(boundary_layer)
    line_width = max(2, size[0] // 900)
    for geometry in geometries:
        outer = projected_ring(geometry.outer, size)
        if len(outer) >= 2:
            boundary_draw.line(
                outer,
                fill=(77, 89, 53, 145),
                width=line_width,
                joint="curve",
            )
        for hole in geometry.holes:
            projected_hole = projected_ring(hole, size)
            if len(projected_hole) >= 2:
                boundary_draw.line(
                    projected_hole,
                    fill=(61, 103, 104, 120),
                    width=line_width,
                    joint="curve",
                )
    return Image.alpha_composite(composed, boundary_layer)


def draw_physical_geography(
    image: Image.Image,
    geometries: tuple[PolygonGeometry, ...],
) -> Image.Image:
    size = image.size
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    river_width = max(2, size[0] // 560)
    for river in MAJOR_RIVERS:
        points = [project(longitude, latitude, size) for longitude, latitude in river]
        draw.line(
            points,
            fill=(26, 126, 177, 210),
            width=river_width + 2,
            joint="curve",
        )
        draw.line(
            points,
            fill=(109, 211, 231, 235),
            width=river_width,
            joint="curve",
        )

    mountain_scale = size[0] / BLUEPRINT_SIZE[0]
    mountain_step = 0.33
    for index in range(len(APPALACHIAN_SPINE) - 1):
        lat_a, lon_a = APPALACHIAN_SPINE[index]
        lat_b, lon_b = APPALACHIAN_SPINE[index + 1]
        distance = math.hypot(lat_b - lat_a, lon_b - lon_a)
        count = max(1, round(distance / mountain_step))
        for step in range(count):
            t = step / count
            latitude = lat_a + (lat_b - lat_a) * t
            longitude = lon_a + (lon_b - lon_a) * t
            x, y = project(longitude, latitude, size)
            jitter = math.sin((index * 17 + step) * 1.7) * 6 * mountain_scale
            x += jitter
            half_width = 9 * mountain_scale
            height = 14 * mountain_scale
            draw.polygon(
                (
                    (x - half_width, y + height / 2),
                    (x, y - height),
                    (x + half_width, y + height / 2),
                ),
                fill=(100, 104, 65, 190),
                outline=(67, 72, 49, 205),
            )
            draw.line(
                (
                    (x, y - height),
                    (x - half_width * 0.15, y + height * 0.05),
                    (x - half_width, y + height / 2),
                ),
                fill=(222, 220, 159, 205),
                width=max(1, round(2 * mountain_scale)),
            )

    return Image.alpha_composite(image.convert("RGBA"), layer)


def render_blueprint(
    kml_path: Path,
    output_path: Path,
    size: tuple[int, int] = BLUEPRINT_SIZE,
) -> None:
    geometries = load_state_polygons(kml_path)
    ocean = build_ocean(size)
    map_image = render_land(ocean, geometries)
    map_image = draw_physical_geography(map_image, geometries)

    wave_layer = Image.new("RGBA", size, (0, 0, 0, 0))
    wave_draw = ImageDraw.Draw(wave_layer)
    rng = random.Random(1776)
    for _ in range(round(size[0] * size[1] / 26000)):
        longitude = rng.uniform(-70.5, -64.8)
        latitude = rng.uniform(31.2, 45.5)
        x, y = project(longitude, latitude, size)
        width = rng.uniform(10, 24) * size[0] / BLUEPRINT_SIZE[0]
        wave_draw.arc(
            (x - width, y - width / 3, x + width, y + width / 3),
            195,
            345,
            fill=(220, 251, 247, 115),
            width=max(1, size[0] // 850),
        )
    map_image = Image.alpha_composite(map_image, wave_layer)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    map_image.convert("RGB").save(output_path, "PNG", optimize=True)


def curve_points(
    start: tuple[float, float],
    end: tuple[float, float],
    index: int,
    steps: int = 120,
) -> list[tuple[float, float]]:
    dx = end[0] - start[0]
    dy = end[1] - start[1]
    length = max(1.0, math.hypot(dx, dy))
    normal_x = -dy / length
    normal_y = dx / length
    bow = min(180.0, length * 0.21)
    if index in (3, 4, 5):
        bow = abs(bow)
    elif index in (10, 11, 12):
        bow = -abs(bow)
    else:
        bow *= -1 if index % 2 else 1

    control_a = (
        start[0] + dx / 3 + normal_x * bow,
        start[1] + dy / 3 + normal_y * bow,
    )
    control_b = (
        start[0] + dx * 2 / 3 + normal_x * bow,
        start[1] + dy * 2 / 3 + normal_y * bow,
    )

    result = []
    for step in range(steps + 1):
        t = step / steps
        inverse = 1 - t
        x = (
            inverse**3 * start[0]
            + 3 * inverse**2 * t * control_a[0]
            + 3 * inverse * t**2 * control_b[0]
            + t**3 * end[0]
        )
        y = (
            inverse**3 * start[1]
            + 3 * inverse**2 * t * control_a[1]
            + 3 * inverse * t**2 * control_b[1]
            + t**3 * end[1]
        )
        result.append((x, y))
    return result


def draw_dotted_route(
    draw: ImageDraw.ImageDraw,
    points: list[tuple[float, float]],
) -> None:
    spacing = 26.0
    carry = 0.0
    for start, end in zip(points, points[1:]):
        dx = end[0] - start[0]
        dy = end[1] - start[1]
        length = math.hypot(dx, dy)
        if length <= 0:
            continue
        distance = spacing - carry
        while distance <= length:
            t = distance / length
            x = start[0] + dx * t
            y = start[1] + dy * t
            draw.ellipse(
                (x - 7, y - 7, x + 7, y + 7),
                fill=(83, 34, 28, 185),
            )
            draw.ellipse(
                (x - 3, y - 3, x + 3, y + 3),
                fill=(255, 222, 102, 235),
            )
            distance += spacing
        carry = max(0.0, length - (distance - spacing))


def chamfered_box(
    draw: ImageDraw.ImageDraw,
    bounds: tuple[int, int, int, int],
    fill: tuple[int, int, int, int],
    outline: tuple[int, int, int, int],
    width: int,
    chamfer: int,
) -> None:
    left, top, right, bottom = bounds
    points = (
        (left + chamfer, top),
        (right - chamfer, top),
        (right, top + chamfer),
        (right, bottom - chamfer),
        (right - chamfer, bottom),
        (left + chamfer, bottom),
        (left, bottom - chamfer),
        (left, top + chamfer),
    )
    draw.polygon(points, fill=fill)
    draw.line(points + (points[0],), fill=outline, width=width, joint="curve")


def draw_title(draw: ImageDraw.ImageDraw) -> None:
    offset_x, offset_y = TITLE_OFFSET
    shadow = (
        74 + offset_x,
        65 + offset_y,
        992 + offset_x,
        260 + offset_y,
    )
    bounds = (
        60 + offset_x,
        51 + offset_y,
        978 + offset_x,
        246 + offset_y,
    )
    chamfered_box(draw, shadow, (60, 38, 22, 90), (60, 38, 22, 80), 2, 17)
    chamfered_box(draw, bounds, (255, 242, 187, 245), (105, 61, 28, 245), 6, 17)
    draw.line(
        (
            90 + offset_x,
            187 + offset_y,
            947 + offset_x,
            187 + offset_y,
        ),
        fill=(190, 132, 39, 220),
        width=4,
    )

    title_font = ImageFont.truetype(str(SERIF_BOLD), 80)
    subtitle_font = ImageFont.truetype(str(SERIF_BOLD), 26)
    draw.text(
        (105 + offset_x, 69 + offset_y),
        "REDCOAT RAID",
        font=title_font,
        fill=(105, 27, 30, 255),
        stroke_width=2,
        stroke_fill=(231, 170, 45, 255),
    )
    draw.text(
        (107 + offset_x, 209 + offset_y),
        "MAIN CAMPAIGN  |  13 COLONIES  |  1775-1780",
        font=subtitle_font,
        fill=(64, 42, 26, 255),
        anchor="lm",
    )


def draw_compass(draw: ImageDraw.ImageDraw, center: tuple[int, int]) -> None:
    x, y = center
    radius = 102

    def polar_point(distance: float, degrees: float) -> tuple[float, float]:
        angle = math.radians(degrees)
        return (x + math.cos(angle) * distance, y + math.sin(angle) * distance)

    draw.ellipse(
        (x - radius + 9, y - radius + 12, x + radius + 9, y + radius + 12),
        fill=(30, 24, 17, 90),
    )

    for index in range(16):
        flourish = polar_point(radius, -90 + index * 22.5)
        flourish_radius = 8 if index % 2 == 0 else 6
        draw.ellipse(
            (
                flourish[0] - flourish_radius,
                flourish[1] - flourish_radius,
                flourish[0] + flourish_radius,
                flourish[1] + flourish_radius,
            ),
            fill=(235, 205, 117, 235),
            outline=(83, 51, 27, 245),
            width=2,
        )

    draw.ellipse(
        (x - radius, y - radius, x + radius, y + radius),
        fill=(247, 232, 171, 222),
        outline=(77, 49, 28, 245),
        width=7,
    )
    draw.ellipse(
        (x - 91, y - 91, x + 91, y + 91),
        outline=(202, 151, 48, 245),
        width=4,
    )
    draw.ellipse(
        (x - 72, y - 72, x + 72, y + 72),
        fill=(240, 224, 158, 90),
        outline=(112, 72, 35, 225),
        width=4,
    )

    for index in range(32):
        angle = -90 + index * 11.25
        inner_radius = 82 if index % 4 == 0 else 87
        width = 4 if index % 8 == 0 else 2
        draw.line(
            (polar_point(inner_radius, angle), polar_point(96, angle)),
            fill=(87, 54, 29, 225),
            width=width,
        )

    for index, angle in enumerate(range(-90, 270, 45)):
        cardinal = index % 2 == 0
        length = 79 if cardinal else 56
        base_distance = 10 if cardinal else 12
        half_width = 14 if cardinal else 10
        radians = math.radians(angle)
        direction = (math.cos(radians), math.sin(radians))
        perpendicular = (-direction[1], direction[0])
        base = (
            x + direction[0] * base_distance,
            y + direction[1] * base_distance,
        )
        triangle = (
            polar_point(length, angle),
            (
                base[0] + perpendicular[0] * half_width,
                base[1] + perpendicular[1] * half_width,
            ),
            (
                base[0] - perpendicular[0] * half_width,
                base[1] - perpendicular[1] * half_width,
            ),
        )
        fill = (105, 31, 35, 250) if cardinal else (32, 76, 97, 240)
        draw.polygon(
            triangle,
            fill=fill,
            outline=(69, 43, 25, 255),
        )

        inset_triangle = (
            polar_point(length - 13, angle),
            (
                base[0] + perpendicular[0] * (half_width * 0.34),
                base[1] + perpendicular[1] * (half_width * 0.34),
            ),
            (
                base[0] - perpendicular[0] * (half_width * 0.34),
                base[1] - perpendicular[1] * (half_width * 0.34),
            ),
        )
        draw.polygon(inset_triangle, fill=(247, 211, 91, 245))

    for angle in range(-90, 270, 45):
        rivet = polar_point(87, angle)
        draw.ellipse(
            (rivet[0] - 3, rivet[1] - 3, rivet[0] + 3, rivet[1] + 3),
            fill=(110, 64, 28, 255),
            outline=(255, 224, 124, 245),
            width=1,
        )

    for angle in (-45, 45, 135, 225):
        inner = polar_point(104, angle)
        outer = polar_point(116, angle)
        draw.line((inner, outer), fill=(98, 57, 27, 245), width=3)
        draw.ellipse(
            (outer[0] - 5, outer[1] - 5, outer[0] + 5, outer[1] + 5),
            fill=(247, 211, 91, 255),
            outline=(78, 46, 25, 255),
            width=2,
        )
        curl = polar_point(121, angle)
        draw.arc(
            (curl[0] - 10, curl[1] - 10, curl[0] + 10, curl[1] + 10),
            start=angle + 35,
            end=angle + 300,
            fill=(181, 126, 37, 235),
            width=3,
        )

    draw.ellipse(
        (x - 16, y - 16, x + 16, y + 16),
        fill=(93, 31, 34, 255),
        outline=(69, 43, 25, 255),
        width=3,
    )
    draw.ellipse(
        (x - 8, y - 8, x + 8, y + 8),
        fill=(250, 213, 88, 255),
        outline=(255, 239, 165, 255),
        width=2,
    )

    # A small fleur-like cap makes north unmistakable without obscuring the rose.
    north_tip = polar_point(104, -90)
    draw.polygon(
        (
            north_tip,
            (x - 8, y - 82),
            (x, y - 88),
            (x + 8, y - 82),
        ),
        fill=(105, 31, 35, 255),
        outline=(69, 43, 25, 255),
    )
    draw.ellipse(
        (x - 17, y - 91, x - 4, y - 78),
        fill=(247, 211, 91, 245),
        outline=(105, 60, 28, 245),
        width=2,
    )
    draw.ellipse(
        (x + 4, y - 91, x + 17, y - 78),
        fill=(247, 211, 91, 245),
        outline=(105, 60, 28, 245),
        width=2,
    )

    cardinal_font = ImageFont.truetype(str(SERIF_BOLD), 23)
    north_font = ImageFont.truetype(str(SERIF_BOLD), 28)
    label_color = (76, 43, 25, 255)
    draw.text((x, y - 128), "N", font=north_font, fill=label_color, anchor="mm")
    draw.text((x + 122, y), "E", font=cardinal_font, fill=label_color, anchor="mm")
    draw.text((x, y + 120), "S", font=cardinal_font, fill=label_color, anchor="mm")
    draw.text((x - 122, y), "W", font=cardinal_font, fill=label_color, anchor="mm")


def draw_region_labels(draw: ImageDraw.ImageDraw) -> None:
    region_font = ImageFont.truetype(str(SERIF_BOLD), 32)
    canada_font = ImageFont.truetype(str(SERIF_BOLD), 38)
    for label, latitude, longitude in REGION_LABELS:
        x, y = project(longitude, latitude, FINAL_SIZE)
        draw.text(
            (x, y),
            label,
            font=canada_font if label == "CANADA" else region_font,
            fill=(56, 63, 37, 165 if label == "CANADA" else 150),
            stroke_width=1,
            stroke_fill=(255, 248, 203, 135),
            anchor="mm",
        )

    ocean_font = ImageFont.truetype(str(SERIF_ITALIC), 39)
    draw.text(
        project(-66.35, 37.2, FINAL_SIZE),
        "ATLANTIC OCEAN",
        font=ocean_font,
        fill=(238, 254, 241, 135),
        stroke_width=1,
        stroke_fill=(24, 95, 143, 90),
        anchor="mm",
    )


def draw_badge(
    draw: ImageDraw.ImageDraw,
    center: tuple[float, float],
    number: int,
    palette: MapPalette,
) -> None:
    x, y = center
    radius = round(44 * BADGE_SCALE)
    ring_radius = round(38 * BADGE_SCALE)
    center_radius = round(30 * BADGE_SCALE)
    draw.ellipse(
        (
            x - radius + round(7 * BADGE_SCALE),
            y - radius + round(10 * BADGE_SCALE),
            x + radius + round(9 * BADGE_SCALE),
            y + radius + round(12 * BADGE_SCALE),
        ),
        fill=(30, 25, 18, 105),
    )
    draw.ellipse(
        (x - radius, y - radius, x + radius, y + radius),
        fill=(*palette.badge_outer, 255),
        outline=(*palette.badge_outer_outline, 255),
        width=4,
    )
    draw.ellipse(
        (
            x - ring_radius,
            y - ring_radius,
            x + ring_radius,
            y + ring_radius,
        ),
        fill=(*palette.badge_ring, 255),
        outline=(*palette.badge_ring_outline, 255),
        width=4,
    )
    draw.ellipse(
        (
            x - center_radius,
            y - center_radius,
            x + center_radius,
            y + center_radius,
        ),
        fill=(*palette.badge_center, 255),
        outline=(*palette.badge_center_outline, 255),
        width=3,
    )
    number_font = ImageFont.truetype(
        str(SERIF_BOLD),
        round((38 if number < 10 else 31) * NUMBER_SCALE),
    )
    draw.text(
        (x, y - 1),
        str(number),
        font=number_font,
        fill=(*palette.ordinal, 255),
        stroke_width=2,
        stroke_fill=(*palette.ordinal_outline, 255),
        anchor="mm",
    )


def draw_label(
    draw: ImageDraw.ImageDraw,
    stop: CampaignStop,
    badge_center: tuple[float, float],
) -> None:
    name_font = ImageFont.truetype(
        str(SERIF_BOLD),
        round(29 * LABEL_SCALE),
    )
    date_font = ImageFont.truetype(
        str(SERIF_BOLD),
        round(17 * LABEL_SCALE),
    )
    name_bounds = draw.textbbox((0, 0), stop.name, font=name_font)
    date_bounds = draw.textbbox((0, 0), stop.date_label, font=date_font)
    width = max(
        name_bounds[2] - name_bounds[0],
        date_bounds[2] - date_bounds[0],
    ) + round(45 * LABEL_SCALE)
    height = round(67 * LABEL_SCALE)
    x, y = badge_center

    if stop.label_side == "top-left":
        left = round(x - 25 * LABEL_SCALE - width)
        top = round(y - 70 * LABEL_SCALE - height)
    elif stop.label_side == "left":
        left = round(x - 55 * LABEL_SCALE - width)
    else:
        left = round(x + 52 * LABEL_SCALE)
    if stop.label_side != "top-left":
        top = round(y - height / 2)
    right = left + width
    bottom = top + height

    left = max(18, min(left, FINAL_SIZE[0] - width - 18))
    top = max(18, min(top, FINAL_SIZE[1] - height - 18))
    right = left + width
    bottom = top + height

    chamfered_box(
        draw,
        (left + 7, top + 8, right + 7, bottom + 8),
        (38, 26, 17, 105),
        (38, 26, 17, 80),
        2,
        10,
    )
    chamfered_box(
        draw,
        (left, top, right, bottom),
        (255, 241, 191, 247),
        (104, 65, 31, 245),
        4,
        10,
    )
    draw.text(
        (
            left + round(22 * LABEL_SCALE),
            top + round(11 * LABEL_SCALE),
        ),
        stop.name,
        font=name_font,
        fill=(50, 34, 20, 255),
    )
    draw.text(
        (
            left + round(23 * LABEL_SCALE),
            top + round(47 * LABEL_SCALE),
        ),
        stop.date_label,
        font=date_font,
        fill=(125, 50, 38, 245),
        anchor="lm",
    )


def build_state_mask(
    geometries: tuple[PolygonGeometry, ...],
    state_names: tuple[str, ...],
    size: tuple[int, int],
) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    selected_states = set(state_names)
    for geometry in geometries:
        if geometry.state_name not in selected_states:
            continue
        outer = projected_ring(geometry.outer, size)
        if len(outer) < 3:
            continue
        draw.polygon(outer, fill=255)
        for hole in geometry.holes:
            projected_hole = projected_ring(hole, size)
            if len(projected_hole) >= 3:
                draw.polygon(projected_hole, fill=0)
    return mask


def build_colony_masks(
    geometries: tuple[PolygonGeometry, ...],
) -> tuple[tuple[str, Image.Image], ...]:
    return tuple(
        (
            colony_name,
            build_state_mask(geometries, (colony_name,), FINAL_SIZE),
        )
        for colony_name in COLONIES_1775
    )


def draw_colonial_borders(
    layer: Image.Image,
    colony_masks: tuple[tuple[str, Image.Image], ...],
    palette: MapPalette,
) -> None:
    combined_edges = Image.new("L", FINAL_SIZE, 0)
    colony_union = Image.new("L", FINAL_SIZE, 0)
    for _colony_name, colony_mask in colony_masks:
        edges = colony_mask.filter(ImageFilter.FIND_EDGES)
        combined_edges = ImageChops.lighter(combined_edges, edges)
        colony_union = ImageChops.lighter(colony_union, colony_mask)

    # The painted map already supplies its coastline. Keep the historical
    # inter-colony divisions, but remove the shared outer perimeter so a second,
    # conflicting coastline or Proclamation boundary is not introduced.
    outer_perimeter = colony_union.filter(ImageFilter.FIND_EDGES).filter(
        ImageFilter.MaxFilter(21)
    )
    combined_edges = ImageChops.subtract(combined_edges, outer_perimeter)

    dark_stroke = combined_edges.filter(ImageFilter.MaxFilter(15))
    dark_layer = Image.new("RGBA", FINAL_SIZE, (*palette.border_outer, 0))
    dark_layer.putalpha(dark_stroke.point(lambda value: round(value * 0.96)))
    layer.alpha_composite(dark_layer)

    gold_stroke = combined_edges.filter(ImageFilter.MaxFilter(7))
    gold_layer = Image.new("RGBA", FINAL_SIZE, (*palette.border_inner, 0))
    gold_layer.putalpha(gold_stroke.point(lambda value: round(value * 0.98)))
    layer.alpha_composite(gold_layer)


def draw_colonial_border_key(
    draw: ImageDraw.ImageDraw,
    palette: MapPalette,
) -> None:
    y = 94
    draw.line(
        (1210, y, 1330, y),
        fill=(*palette.border_outer, 255),
        width=15,
    )
    draw.line(
        (1210, y, 1330, y),
        fill=(*palette.border_inner, 255),
        width=7,
    )
    font = ImageFont.truetype(str(SERIF_BOLD), 24)
    draw.text(
        (1349, y),
        "1775 COLONY BORDER",
        font=font,
        fill=(*palette.border_outer, 255),
        stroke_width=3,
        stroke_fill=(*palette.border_inner, 235),
        anchor="lm",
    )


def render_final(
    colony_geojson_path: Path,
    database_path: Path,
    input_path: Path,
    output_path: Path,
    palette: MapPalette,
) -> None:
    stops = load_main_campaign_stops(database_path)
    geometries = load_colony_polygons(colony_geojson_path)
    with Image.open(input_path) as source:
        painted = ImageOps.fit(
            source.convert("RGB"),
            FINAL_SIZE,
            method=Image.Resampling.LANCZOS,
            centering=(0.5, 0.5),
        )

    painted = ImageEnhance.Brightness(painted).enhance(1.14)
    painted = ImageEnhance.Color(painted).enhance(1.12)
    painted = ImageEnhance.Contrast(painted).enhance(1.025)
    painted = ImageEnhance.Sharpness(painted).enhance(1.06)

    colony_masks = build_colony_masks(geometries)
    overlay = Image.new("RGBA", FINAL_SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw_region_labels(draw)

    anchors = [
        project(stop.longitude, stop.latitude, FINAL_SIZE)
        for stop in stops
    ]
    for index, (start, end) in enumerate(zip(anchors, anchors[1:])):
        draw_dotted_route(draw, curve_points(start, end, index))

    draw_colonial_borders(overlay, colony_masks, palette)
    draw = ImageDraw.Draw(overlay)

    scale_x = FINAL_SIZE[0] / BLUEPRINT_SIZE[0]
    scale_y = FINAL_SIZE[1] / BLUEPRINT_SIZE[1]
    for stop, anchor in zip(stops, anchors):
        badge_center = (
            anchor[0] + stop.badge_offset[0] * scale_x,
            anchor[1] + stop.badge_offset[1] * scale_y,
        )
        draw.line(
            (anchor, badge_center),
            fill=(80, 48, 25, 210),
            width=4,
        )
        draw.ellipse(
            (
                anchor[0] - 9,
                anchor[1] - 9,
                anchor[0] + 9,
                anchor[1] + 9,
            ),
            fill=(255, 224, 103, 255),
            outline=(91, 44, 28, 255),
            width=3,
        )
        draw_label(draw, stop, badge_center)
        draw_badge(draw, badge_center, stop.number, palette)

    draw_title(draw)
    draw_colonial_border_key(draw, palette)
    draw_compass(draw, (2574, 1530))

    final = Image.alpha_composite(painted.convert("RGBA"), overlay).convert("RGB")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    final.save(output_path, "PNG", optimize=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render the geographically grounded Redcoat Raid campaign map."
    )
    parser.add_argument(
        "--mode",
        choices=("blueprint", "final"),
        required=True,
    )
    parser.add_argument("--kml", type=Path)
    parser.add_argument(
        "--colonies-geojson",
        type=Path,
        default=DEFAULT_COLONIES_GEOJSON,
    )
    parser.add_argument(
        "--database",
        type=Path,
        default=DEFAULT_DATABASE,
    )
    parser.add_argument("--input", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument(
        "--palette",
        choices=tuple(PALETTES),
        default="burgundy-gold",
    )
    arguments = parser.parse_args()
    if arguments.mode == "blueprint" and arguments.kml is None:
        parser.error("--kml is required in blueprint mode")
    if arguments.mode == "final" and arguments.input is None:
        parser.error("--input is required in final mode")
    return arguments


if __name__ == "__main__":
    args = parse_args()
    if args.mode == "blueprint":
        render_blueprint(args.kml, args.output)
    else:
        render_final(
            args.colonies_geojson,
            args.database,
            args.input,
            args.output,
            PALETTES[args.palette],
        )
