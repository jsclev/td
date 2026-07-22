// GameClock.swift
// A stateful, fixed-timestep clock that advances *logical* game time in
// discrete ticks, decoupled from wall-clock time. This is the game's own
// timer: headless callers (the simulator, tests) drive it as fast as the CPU
// allows, so a run is deterministic and reproducible; a real-time front end
// would instead call `advance()` once per tick's worth of elapsed real time.
//
// SimClock defines the quantum (30 ticks/sec); GameClock is the running clock
// built on that quantum. Keeping the two apart means the simulation math stays
// a pure function of `dt`, while *when* those steps happen is this class's job.
public final class GameClock {
    /// Fixed simulation rate. Every tick advances `dt` seconds of game time.
    public let ticksPerSecond: Int
    public let dt: Double

    /// Completed ticks since the last reset.
    public private(set) var tick: Int = 0
    /// Elapsed game time in seconds. Derived from `tick` (not accumulated) so
    /// long runs never drift from floating-point error.
    public private(set) var time: Double = 0

    public init(ticksPerSecond: Int = SimClock.ticksPerSecond) {
        precondition(ticksPerSecond > 0, "ticksPerSecond must be positive")
        self.ticksPerSecond = ticksPerSecond
        self.dt = 1.0 / Double(ticksPerSecond)
    }

    /// Advance one fixed step and return the new game time.
    @discardableResult
    public func advance() -> Double {
        tick += 1
        time = Double(tick) * dt
        return time
    }

    /// Advance a whole number of ticks, invoking `body` after each one.
    public func advance(ticks: Int, _ body: (GameClock) -> Void) {
        precondition(ticks >= 0, "cannot advance a negative number of ticks")
        for _ in 0..<ticks {
            advance()
            body(self)
        }
    }

    /// Advance until at least `seconds` more game time has elapsed, invoking
    /// `body` after each tick. Runs headless: no sleeping, no real-time pacing.
    public func run(for seconds: Double, _ body: (GameClock) -> Void) {
        let target = time + seconds
        // Compare against the next tick's time so a whole final tick that lands
        // exactly on `target` is still taken.
        while time + dt <= target + 1e-9 {
            advance()
            body(self)
        }
    }

    /// Restart from tick 0 / time 0. The quantum is unchanged.
    public func reset() {
        tick = 0
        time = 0
    }
}
