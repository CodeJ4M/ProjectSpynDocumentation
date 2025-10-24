global key
InitKeyboard();
while 1
    pause(0.1);
    switch key
        case 'uparrow'
            %disp('Up');
            brick.MoveMotor('A', 20);
            brick.MoveMotor('D', 18.5);
            
        case 'downarrow'
            %disp('Down');
            brick.MoveMotor('A', -20);
            brick.MoveMotor('D', -19);
            
        case 'leftarrow'
            brick.MoveMotor('A', 10);
            brick.MoveMotor('D', -10);
            
        case 'rightarrow'
            brick.MoveMotor('A', -10);
            brick.MoveMotor('D', 10);
            
        case 0
            %disp('No Input');
            brick.StopMotor('ADC', 'Coast');
            
        case 'w'
            %disp('Claw Up');
            brick.MoveMotor('C', -10);
            
        case 's'
            %disp('Claw Down');
            brick.MoveMotor('C', 10);
            
        case 'q'
            break;
    end
end

CloseKeyboard();

