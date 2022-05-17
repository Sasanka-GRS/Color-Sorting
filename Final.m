% Arduino Stuff
clear all

a = arduino('COM7', 'Uno', 'Libraries', 'Servo'); %Initialize arduino at COM PORT 
cam = webcam(1);

s1 = servo(a, 'D3');                %Initialize servo1 at Digital pin 3 of arduino Uno
writePosition(s1,0);
s2 = servo(a, 'D5');                %Initialize servo2 at Digital pin 5 of arduino Uno
writePosition(s2,0);
s3 = servo(a, 'D6');                %Initialize servo3 at Digital pin 6 of arduino Uno
writePosition(s3,0);
dc = 'D8';      %DC motor pin 
pwm1 = 'D11';    %PWM pins
ir = 'D4';      %IR sensor pin
gir = 'D7';
bir = 'D12';

while(1)

    irVal = readDigitalPin(a,'D4');

    if (~irVal)
        % take photo
        pause(0.5);
        im = snapshot(cam);
        %figure()
        %imshow(im);
        
        % Move DC
        
        %If possible implement pwn=m

        %pwm = 'D11';
        %writePWMDutyCycle(a,pwm,0.8);
        %pwm1 = 'D10';
        %writePWMDutyCycle(a,pwm1,0.8);

        %writeDigitalPin(a,pwm1,1);
        
        s = size(im);
        s = size(s);

        if(s(2)~=3)
             im = ind2rgb(im,cmap);
        end

        % image processing
        %figure();
        % Red Detection
        r = im(:,:,1); 
        g = im(:,:,2); 
        b = im(:,:,3); % r = red object g = green and b = blue objects

        RedPart = imsubtract(r,rgb2gray(im));
        RedPart = medfilt2(RedPart,[3 3]);
        BlackNWhite = imbinarize(RedPart,0.2);
        area_r = bwareaopen(BlackNWhite,300);
        R = sum(area_r(:));
        rm = immultiply(area_r,r);  
        gm = g.*0;
        bm = b.*0;

        FinalDetectionRed = cat(3,rm,gm,bm);
        %subplot(3,1,1);
        %imshow(FinalDetectionRed);
        %title('RED');                              
    
        % Green color detection 
        GreenPart = imsubtract(g,rgb2gray(im));
        GreenPart = medfilt2(GreenPart,[3 3]);
        BlackNWhite = imbinarize(GreenPart,0.071);
        area_g = bwareaopen(BlackNWhite,300);
        G = sum(area_g(:));
        gm = immultiply(area_g,g);
        rm = r.*0;  
        bm = b.*0;

        FinalDetectionGreen = cat(3,rm,gm,bm);
        %subplot(3,1,2);
        %imshow(FinalDetectionGreen);
        %title('GREEN');
     
        % Blue color detection
        BluePart = imsubtract(b,rgb2gray(im));
        BluePart = medfilt2(BluePart,[3 3]);
        BlackNWhite = imbinarize(BluePart,0.2);
        area_b = bwareaopen(BlackNWhite,300);
        B=sum(area_b(:));
        bm=immultiply(area_b,b);  
        gm = g.*0;  
        rm = r.*0;

        FinalDetectionBlue = cat(3,rm,gm,bm);
        %subplot(3,1,3);
        %imshow(FinalDetectionBlue);
        %title('BLUE');
        
        % servo actuation
        if((R>G) && (R>B))
            disp('RED');
            pause(0.5);
            writePosition(s1,(2/3));
            pause(0.5);
            writePosition(s1,0);
        elseif((G>R) && (G>B))
            writeDigitalPin(a,dc,1); 
            writePWMDutyCycle(a,pwm1,0.6);
            % Stop DC
            GIR = 1;
            while(GIR)
                GIR = readDigitalPin(a,gir);
            end
            %Add sufficient delay for G
            writeDigitalPin(a,'D8',0);
            disp('GREEN');
            pause(0.5);
            writePosition(s2,(2/3));
            pause(0.5);
            writePosition(s2,0);
        elseif((B>R) && (B>G))
            writeDigitalPin(a,dc,1); 
            writePWMDutyCycle(a,pwm1,0.6);
            % Stop DC
            BIR = 1;
            while(BIR)
                BIR = readDigitalPin(a,bir);
            end
            %Add sufficient delay for B
            writeDigitalPin(a,'D8',0);
            disp('BLUE');
            pause(0.5);
            writePosition(s3,(2/3));
            pause(0.5);
            writePosition(s3,0);
        else
            writeDigitalPin(a,'D8',0);
            disp('NONE');
        end

     else
        writeDigitalPin(a,'D8',0);        
    end
end