%{
ports:
ultrasonic: 1
color: 2
touch: 3
left motor:  A
right motor: D
%}

% ===== Motor speed settings =====
motorlf = 85;     % Left motor forward (A)
motorrf = 85;     % Right motor forward (D)
motorlb = -30;    % Left motor backward
motorrb = -30;    % Right motor backward
threshold = 49;   % Distance threshold (cm)

% ===== Initialize sensors =====
brick.SetColorMode(2, 2); % Color sensor in color code mode
disp('Starting Maze Navigation');
startTime = tic;  % Timer to track first 3 seconds

% ===== Variables =====
% last_bump_time = 0;  SCRAPPED 
% bump_timeout = 8;       Double-bump window (SCRAPPED)
colorDelay = 3;        % Delay before color detection (seconds)

while true
    % ===== MOVE FORWARD =====
    brick.MoveMotor('A', motorlf);
    brick.MoveMotor('D', motorrf);

    % ===== SENSOR READINGS =====
    touch = brick.TouchPressed(3);
    color = brick.ColorCode(2);
    distance = brick.UltrasonicDist(1);
    elapsedTime = toc(startTime);

    % ===== ULTRASONIC CHECK (Always Active) =====
    if distance > threshold
        brick.StopMotor('AD', 'Brake');
        pause(0.3);

        % Turn RIGHT 90°
        brick.MoveMotor('D', 55);
        pause(0.9);
        brick.StopMotor('D', 'Brake');

        % Move forward after turning
        brick.MoveMotor('A', motorlf);
        brick.MoveMotor('D', motorrf);
        pause(1);
    end

    % ===== COLOR DETECTION =====
    if elapsedTime > colorDelay
        if color == 5  % RED
            disp('RED detected — stopping.');
            brick.StopMotor('AD', 'Brake');
            pause(3);
            break; % End program after red

        elseif color == 7  % BLUE
            disp('BLUE detected ');
            brick.StopMotor('AD', 'Brake');
            break; % End program after blue

        elseif color == 3  % GREEN
            disp('GREEN detected');
            brick.StopMotor('AD', 'Brake');
            break; % End program after green
        end
    end

    % ===== TOUCH SENSOR BEHAVIOR =====
    if touch
        current_time = toc;
        disp('Bumper pressed — backing up and turning left.');

        % Stop
        brick.StopMotor('AD', 'Brake');
        pause(0.2);

        % Back up for space
        brick.MoveMotor('A', motorlb);
        brick.MoveMotor('D', motorrb);
        pause(1.7);
        brick.StopMotor('AD', 'Brake');
        pause(0.3);

        % Turn LEFT 90°
        brick.MoveMotor('A', 55);
        pause(0.9);
        brick.StopMotor('A', 'Brake');

    end
end
