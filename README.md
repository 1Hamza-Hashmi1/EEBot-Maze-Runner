# EEBot-Maze-Runner

## Project Discription
The EEBOT Maze Runner Project focused on programming a robot (EEBOT) with assembly language code to autonomously navigate complex mazes using different algorithms. The main objectives were to direct the robot through a maze, enable it to make decisions at intersections, and find its way out of dead ends. This project involved integrating sensors, LCD displays, and motors, along with developing software routines to efficiently manage these components.

## Code Breakdown
Initialization and Configuration: Established foundational elements, defined constants, initialized sensors, configured timers, and set up variables for data conversion.
<br>
<br>
Decision-Making with Dispatcher: Developed a Dispatcher module to make decisions based on the robot's current state, determining if the robot should move forward, turn, or stop.
<br>
<br>
Interactions with LCD: Initialized Analog to Digital Converter (ADC) subroutines for communication with the LCD, allowing the ADC to read analog sensor values and convert them to digital for real-time user feedback.
<br>
<br>
Navigation: Created navigation logic using sensors to enable the robot to execute right or left turns based on specific instructions and algorithms.
<br>
<br>
Data Conversion: Developed subroutines to convert data between formats (e.g., BCD to ASCII) for tasks such as displaying numbers on the LCD.
