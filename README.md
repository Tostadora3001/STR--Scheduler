[!NOTE]
This README was mainly did with IA

# STR Scheduler Project

This project is a real-time scheduling tool implemented in x86 assembly for Linux. It supports three scheduling strategies:

- **Cyclic scheduling** (`c`)
- **Deadline-based feasibility analysis** (`d`)
- **Fixed-priority / Monotonic scheduling** (`f`)

The project is distributed as assembly source files and assembled with GNU `as` and linked with `ld` using the provided `Makefile`.

## Project Structure

- `Makefile` - build rules for assembling and linking the program.
- `src/Main.s` - program entry point, user interaction, task input collection, and scheduler selection.
- `src/Schedule.s` - core scheduling algorithms and feasibility checks.
- `src/Utils.s` - utility routines for number parsing, arithmetic, sorting, and error handling.
- `src/Terminal_functions.s` - simple terminal I/O wrappers using Linux syscalls.
- `src/Memory_functions.s` - heap allocation and deallocation helpers via `brk` syscall.

## Requirements

- Linux environment
- GNU assembler (`as`) with 32-bit support
- GNU linker (`ld`) with `-m elf_i386` support
- `make`

> Note: Because the code is assembled as 32-bit x86, your environment must support 32-bit execution and linking. Install the appropriate multilib packages if necessary.

## Build

From the project root (`/home/sergio/UPC/STR/Scripts`):

```bash
make
```

This creates the executable named `Schedule` and removes intermediate object files.

## Clean

```bash
make clean
```

Removes generated object files and the `Schedule` executable.

## Usage

Run the scheduler from the project root:

```bash
./Schedule
```

The program prompts for:

1. Number of tasks
2. For each task: `Compute time`, `Deadline`, `Period`
3. Scheduling strategy choice:
   - `c` for cyclic scheduling
   - `d` for deadline scheduling
   - `f` for fixed-priority / monotonic scheduling

### Input format

For each task, enter three integer values in sequence. The program expects integer input only and uses newline or whitespace as separators.

Example:

```
3
2 5 10
1 4 7
3 8 12
c
```

## Scheduler Strategies

### Cyclic Scheduling (`c`)

This mode computes:

- The processor utilization factor for the task set.
- The hyperperiod (least common multiple of all task periods).
- Valid frame sizes (`f`) that satisfy the cyclic scheduling constraints.

It evaluates candidate frame values and prints whether each frame is valid or invalid based on real-time cyclic scheduling conditions.

### Deadline Scheduling (`d`)

This mode performs a demand-bound analysis across the hyperperiod.

It computes:

- The processor utilization factor.
- The hyperperiod.
- Feasibility of the task set by verifying that the demand bound function is not greater than the available time window for each relevant point.

If any deadline is missed, the scheduler reports the task set as not feasible.

### Fixed-Priority / Monotonic Scheduling (`f`)

This mode sorts tasks by period and applies fixed-priority analysis using response-time calculations.

It computes:

- The processor utilization factor.
- Response time `R` for each task using interference from higher-priority tasks.
- Whether each task meets its deadline.

The implementation follows a rate-monotonic-like analysis where shorter periods receive higher priority.

## Output

The executable prints informative messages for each chosen strategy, including:

- The selected scheduling strategy
- Utilization factor expressed as a scaled integer over 1000
- Hyperperiod value
- Candidate frame information for cyclic scheduling
- Response-time analysis details for fixed-priority scheduling
- Demand-bound check results for deadline scheduling
- Feasibility or failure status

## Example runs

### Cyclic schedule example

Input:
```
3
2 5 10
1 4 7
3 8 12
c
```
Expected behavior:
- The program prints the cyclic schedule header.
- It calculates utilization and hyperperiod.
- It lists candidate frame values and marks valid or invalid frames.

### Deadline feasibility example

Input:
```
3
1 4 5
2 5 8
1 7 10
d
```
Expected behavior:
- The program prints the deadline schedule header.
- It calculates utilization and hyperperiod.
- It evaluates demand-bound checks across points up to the hyperperiod.
- It reports either a feasible schedule or a deadline failure.

### Fixed-priority / monotonic analysis example

Input:
```
3
1 4 5
2 5 8
1 7 10
f
```
Expected behavior:
- The program prints the fixed-priority schedule header.
- It calculates utilization.
- It sorts tasks by period and computes response times.
- It reports whether each task meets its deadline and whether the set is feasible.

## Implementation Notes

- The program uses direct Linux syscalls for I/O and heap management.
- Task data is stored in memory as triples of 32-bit integers: `Compute time`, `Deadline`, and `Period`.
- The scheduler uses a simple `Bubble_sort_tasks` routine for priority ordering.
- Error conditions cause the program to print an error message and exit.

## Limitations

- Input is strictly integer-based; floating-point values are not supported.
- The code is designed for a single session run and exits after scheduling.
- It depends on 32-bit assembly support in the host environment.

## Notes

This project is useful for studying low-level implementations of real-time scheduling algorithms in assembly language and for exploring STR scheduling concepts in a minimalist Linux environment.
