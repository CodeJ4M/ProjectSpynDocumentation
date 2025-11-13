%{
ports:
ultrasonic: 1
color: 2
touch: 3
left motor:  A
right motor: D
%}

%         Motor speed settings 
motorlf = 85;    % Left motor forward (A)
motorrf = 85;    % Right motor forward (D)
motorlb = -30;     % Left motor backward
motorrb = -30;     % Right motor backward
threshold = 49;   % Distance threshold (cm)

% ===== Initialize sensors =====
brick.SetColorMode(2, 2); % Color sensor in color code mode
disp('Starting Maze Navigation...');
startTime = tic;  % Timer to track first 3 seconds

% ===== Variables =====
ultrasonicEnabled = true;  % Ultrasonic sensor starts active
last_bump_time = 0;        % Track time of last bump
bump_timeout = 5;          % Extended double-bump detection window (seconds)
colorDelay = 3;            % Delay before enabling color detection (seconds)

while true
    % Move Forward
    brick.MoveMotor('A', motorlf);
    brick.MoveMotor('D', motorrf);
    
    % Get Sensor Readings
    touch = brick.TouchPressed(3);
    color = brick.ColorCode(2);
    elapsedTime = toc(startTime);  % Time since program started

    % ===== ULTRASONIC CHECK (only if enabled) =====
    if ultrasonicEnabled
        distance = brick.UltrasonicDist(1);
        if distance > threshold
            disp(['Ultrasonic triggered! Distance: ', num2str(distance), ' cm']);
            
            % Disable ultrasonic until bumper pressed again
            ultrasonicEnabled = false;
            disp('Ultrasonic temporarily disabled until bumper is pressed.');

            % --- Move forward briefly before turning ---
            disp('Moving forward briefly before turn...');
            brick.MoveMotor('A', motorlf);
            brick.MoveMotor('D', motorrf);
            pause(0.40);

            % Stop and turn RIGHT 90 degrees
            brick.StopMotor('AD', 'Brake');
            pause(0.3);

            disp('Turning RIGHT 90 degrees...');
            brick.MoveMotor('D', -55);  % Slightly faster turn speed
            pause(0.9); % Adjusted timing for ~90° turn at higher speed
            brick.StopMotor('D', 'Brake');

            % Resume forward motion
            disp('Continuing forward after turn...');
            brick.MoveMotor('A', motorlf);
            brick.MoveMotor('D', motorrf);
            pause(1)
        end
    end
    
    % ===== COLOR DETECTION (only after first 3 seconds) =====
    if elapsedTime > colorDelay
        if color == 5  % RED
            disp('RED detected - Stopping for 3 seconds');
            brick.StopMotor('AD', 'Brake');
            pause(3);
  
        elseif color == 7 || color == 5  % BLUE
            disp('BLUE detected - Entering manual control');
            brick.StopMotor('AD', 'Brake');
            pause(0.2);
            run('kbrdcontrol');
        end
    end
    
    % ===== TOUCH SENSOR BEHAVIOR =====
    if touch
        current_time = toc;
        disp('Bumper pressed - Backing up and turning LEFT 90°');
        
        % Stop
        brick.StopMotor('AD', 'Brake');
        pause(0.2);
        
        % Back up for space
        brick.MoveMotor('A', motorlb);
        brick.MoveMotor('D', motorrb);
        pause(1.7); % THIS IS BACKUP DISTANCE
        brick.StopMotor('AD', 'Brake');
        pause(0.3);
        
        % Sharp LEFT 90° turn
        brick.MoveMotor('A', -55);
        pause(0.9); 
        brick.StopMotor('A', 'Brake');
        
        % ===== Double-bump logic =====
        if (current_time - last_bump_time) <= bump_timeout && last_bump_time > 0
            disp('Double bump detected — disabling ultrasonic again!');
            ultrasonicEnabled = true;
        else
            disp('Single bump detected — ultrasonic re-enabled.');
            ultrasonicEnabled = true;
        end

        % Update bump timer
        last_bump_time = current_time;
    end
end
