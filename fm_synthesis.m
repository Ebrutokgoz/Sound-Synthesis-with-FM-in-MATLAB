classdef fm_project < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        TabGroup                    matlab.ui.container.TabGroup
        Tab_fm                      matlab.ui.container.Tab
        Image_diagram               matlab.ui.control.Image
        Title                       matlab.ui.control.Label
        Button_play_fmtab           matlab.ui.control.Button
        Panel_mod                   matlab.ui.container.Panel
        DropDown_mod_mul            matlab.ui.control.DropDown
        Label                       matlab.ui.control.Label
        Knob_mod_freq               matlab.ui.control.Knob
        FmKnob_2Label               matlab.ui.control.Label
        DLabel                      matlab.ui.control.Label
        Slider_mod_amp              matlab.ui.control.Slider
        Panel_carrier               matlab.ui.container.Panel
        DropDown_carrier_mul        matlab.ui.control.DropDown
        DropDown_2Label             matlab.ui.control.Label
        Knob_carrier_freq           matlab.ui.control.Knob
        FcKnobLabel                 matlab.ui.control.Label
        Slider_carrier_amp          matlab.ui.control.Slider
        AcSliderLabel               matlab.ui.control.Label
        TextArea                    matlab.ui.control.TextArea
        TextArea_2                  matlab.ui.control.TextArea
        UIAxes_TC                   matlab.ui.control.UIAxes
        UIAxes_TM                   matlab.ui.control.UIAxes
        UIAxes_Result               matlab.ui.control.UIAxes
        UIAxes_FftC                 matlab.ui.control.UIAxes
        UIAxes_FftM                 matlab.ui.control.UIAxes
        UIAxes_FftResult            matlab.ui.control.UIAxes
        Tab_example                 matlab.ui.container.Tab
        Spinner_noise_amp           matlab.ui.control.Spinner
        NoiseamplitudeSpinnerLabel  matlab.ui.control.Label
        Switch_noise                matlab.ui.control.Switch
        Image_gong_wave_2           matlab.ui.control.Image
        Image_gong_wave_1           matlab.ui.control.Image
        Button_play_ex_tab          matlab.ui.control.Button
        Image_gong                  matlab.ui.control.Image
        UIAxes_Envelope             matlab.ui.control.UIAxes
        UIAxes_Gong                 matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        carrier_amp_prev;
            carrier_freq_prev;
            mod_amp_prev;
            mod_freq_prev;

            carrier_amp;                         %A
            carrier_freq;  %C
            mod_amp;                                   %D
            mod_freq; 

            
    end
    
  
    
    methods (Access = public)
        
        function plotFnc(app,A,C,D,M)
            T=0.000001;
            Fs=1/T;
            t = 0:T:.05;  %seconds
            
             y=A*sin(2*pi*C*t+D*sin(2*pi*M*t));
            c=A*sin(2*pi*C*t);
            m=D*sin(2*pi*M*t);
            plot(app.UIAxes_TC,t,c);

            l=length(c);
            Y=fft(c);
            P2 = abs(Y/l);
            P1 = P2(1:(l/2+1));
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(l/2))/l;
            stem(app.UIAxes_FftC,f,P1);
            app.UIAxes_FftC.XLim = [0 max(2*C,100)];

            
            plot(app.UIAxes_TM,t,m);
    
            l=length(m);
            Y=fft(m);
            P2 = abs(Y/l);
            P1 = P2(1:l/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(l/2))/l;
            stem(app.UIAxes_FftM,f,P1);
            app.UIAxes_FftM.XLim = [0 max(2*M,100)];

            
            plot(app.UIAxes_Result,t,y);
       
    
            l=length(y);
            Y=fft(y);
            P2 = abs(Y/l);
            P1 = P2(1:l/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(l/2))/l;
          
            stem(app.UIAxes_FftResult,f,P1);
            app.UIAxes_FftResult.XLim = [0 max(max(2*C,2*M),100)];
         
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           %A=2;
            %C = 210;
            %D = 10;
            %M = 70;
%plotFnc(app,A,C,D,M);
        end

        % Button pushed function: Button_play_fmtab
        function Button_play_fmtabPushed(app, event)
           
        
         T=0.00001;
        Fs=1/T;
        t = 0:T:1;
        %Fs = 44100;
          %  T = 1/Fs;
           % dur = 1.0;
            %t = 0:T:dur; 
        A = app.Slider_carrier_amp.Value;                         %A
            C=app.Knob_carrier_freq.Value*app.DropDown_carrier_mul.Value;  %C
            D=app.Slider_mod_amp.Value;                                   %D
            M= app.Knob_mod_freq.Value*app.DropDown_mod_mul.Value; 
        
            
           
         y=A*sin(2*pi*C*t+D*sin(2*pi*M*t));
        sound(y,Fs);
            
         
        
        end

        % Callback function: DropDown_carrier_mul, DropDown_carrier_mul, 
        % ...and 8 other components
        function valueChanged(app, event)
            A = app.Slider_carrier_amp.Value;                         %A
            C=app.Knob_carrier_freq.Value*app.DropDown_carrier_mul.Value;  %C
            D=app.Slider_mod_amp.Value;                                   %D
            M= app.Knob_mod_freq.Value*app.DropDown_mod_mul.Value; 
           
            plotFnc(app,A,C,D,M);
        end

        % Button pushed function: Button_play_ex_tab
        function Button_play_ex_tabPushed(app, event)
            Fs = 22050;
            T = 1/Fs;
            dur = 7.0;
            t = 0:T:dur;
            T60 = 1.0;
            env = 0.95*exp(-t/T60);

            
            % FM parameters
            fc = 200;
            fm = 280;
            Dmax = 5;
            D = Dmax.*env;
            
            if app.Switch_noise.Value == true
                noise_amp = app.Spinner_noise_amp.Value;
                noise = noise_amp*randn(size(t)); % Generate the noise signal
            else
                noise = 0;
            end
            
            y = sin(2*pi*fc*t + D.*sin(2*pi*fm*t));
            signal = env.*(y + noise);
            
            plot(app.UIAxes_Envelope,env);
            plot(app.UIAxes_Gong,t,signal);
            sound(signal, Fs);
            audiowrite('gongSoundWithNoise.wav', signal, Fs);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.651 0.651 0.651];
            app.UIFigure.Position = [0 0 1299 995];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.Scrollable = 'on';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Position = [9 10 1283 978];

            % Create Tab_fm
            app.Tab_fm = uitab(app.TabGroup);
            app.Tab_fm.AutoResizeChildren = 'off';
            app.Tab_fm.Title = 'FM Sentezi';
            app.Tab_fm.BackgroundColor = [1 1 1];
            app.Tab_fm.ForegroundColor = [0 0.4471 0.7412];

            % Create UIAxes_FftResult
            app.UIAxes_FftResult = uiaxes(app.Tab_fm);
            title(app.UIAxes_FftResult, 'FFT')
            xlabel(app.UIAxes_FftResult, 'Frekans')
            ylabel(app.UIAxes_FftResult, 'Genlik')
            zlabel(app.UIAxes_FftResult, 'Z')
            app.UIAxes_FftResult.Position = [911 38 241 126];

            % Create UIAxes_FftM
            app.UIAxes_FftM = uiaxes(app.Tab_fm);
            title(app.UIAxes_FftM, 'FFT')
            xlabel(app.UIAxes_FftM, 'Frekans')
            ylabel(app.UIAxes_FftM, 'Genlik')
            zlabel(app.UIAxes_FftM, 'Z')
            app.UIAxes_FftM.Position = [911 208 241 126];

            % Create UIAxes_FftC
            app.UIAxes_FftC = uiaxes(app.Tab_fm);
            title(app.UIAxes_FftC, 'FFT')
            xlabel(app.UIAxes_FftC, 'Frekans')
            ylabel(app.UIAxes_FftC, 'Genlik')
            zlabel(app.UIAxes_FftC, 'Z')
            app.UIAxes_FftC.Position = [911 390 241 126];

            % Create UIAxes_Result
            app.UIAxes_Result = uiaxes(app.Tab_fm);
            title(app.UIAxes_Result, 'FM çıktısı')
            xlabel(app.UIAxes_Result, 'Zaman')
            ylabel(app.UIAxes_Result, 'Genlik')
            zlabel(app.UIAxes_Result, 'Z')
            app.UIAxes_Result.Position = [568 33 241 126];

            % Create UIAxes_TM
            app.UIAxes_TM = uiaxes(app.Tab_fm);
            title(app.UIAxes_TM, 'Modülatör')
            xlabel(app.UIAxes_TM, 'Zaman')
            ylabel(app.UIAxes_TM, 'Genlik')
            zlabel(app.UIAxes_TM, 'Z')
            app.UIAxes_TM.Position = [568 208 241 126];

            % Create UIAxes_TC
            app.UIAxes_TC = uiaxes(app.Tab_fm);
            title(app.UIAxes_TC, 'Taşıyıcı')
            xlabel(app.UIAxes_TC, 'Zaman')
            ylabel(app.UIAxes_TC, 'Genlik')
            zlabel(app.UIAxes_TC, 'Z')
            app.UIAxes_TC.Position = [568 390 241 126];

            % Create TextArea_2
            app.TextArea_2 = uitextarea(app.Tab_fm);
            app.TextArea_2.FontName = 'Bookman';
            app.TextArea_2.FontSize = 16;
            app.TextArea_2.FontColor = [0 0.4471 0.7412];
            app.TextArea_2.Position = [783 587 423 243];
            app.TextArea_2.Value = {'  '; '  Temel FM denklemi:  e = Asin(αt + Dsin(βt))'; ''; '  e ,  modüle edilmiş taşıyıcının anlık genliğidir.'; '  A, tepe genliğidir.'; '  α ve β ilgili taşıyıcı ve modülatör frekanslarıdır (fc ve fm).'; '  D, frekans sapma miktarının bir ölçeğidir (modülasyonun '; '  derinliği).'};

            % Create TextArea
            app.TextArea = uitextarea(app.Tab_fm);
            app.TextArea.FontName = 'Bookman';
            app.TextArea.FontSize = 16;
            app.TextArea.FontColor = [0 0.4471 0.7412];
            app.TextArea.Position = [392 587 371 243];
            app.TextArea.Value = {''; '  Biri diğerinden gelen sinyali (sinüs dalgasını) '; '  modüle eden iki osilatör ile çalışır.'; ''; '  Bu iki osilatörün biri modülatör diğeri de '; '  taşıyıcı olarak adlandırılır.'; ''; '  - Osilatör: Dalga formlarını üreten cihaz.'; '  - Taşıyıcı Frekansı (fc): Modüle edilen '; '  osilatörün frekansı'; '  - Modülatör Frekansı (fm): Taşıyıcıyı modüle '; '  eden osilatörün frekansı'};

            % Create Panel_carrier
            app.Panel_carrier = uipanel(app.Tab_fm);
            app.Panel_carrier.AutoResizeChildren = 'off';
            app.Panel_carrier.BorderColor = [0.8 0.8 0.8];
            app.Panel_carrier.ForegroundColor = [1 1 1];
            app.Panel_carrier.BorderWidth = 0.5;
            app.Panel_carrier.Title = '                 Taşıyıcı';
            app.Panel_carrier.BackgroundColor = [0 0.4471 0.7412];
            app.Panel_carrier.FontName = 'Bookman';
            app.Panel_carrier.FontWeight = 'bold';
            app.Panel_carrier.FontSize = 16;
            app.Panel_carrier.Position = [41 145 210 365];

            % Create AcSliderLabel
            app.AcSliderLabel = uilabel(app.Panel_carrier);
            app.AcSliderLabel.HorizontalAlignment = 'right';
            app.AcSliderLabel.Position = [96 301 25 22];
            app.AcSliderLabel.Text = 'Ac';

            % Create Slider_carrier_amp
            app.Slider_carrier_amp = uislider(app.Panel_carrier);
            app.Slider_carrier_amp.Limits = [0 10];
            app.Slider_carrier_amp.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.Slider_carrier_amp.Position = [37 290 143 3];

            % Create FcKnobLabel
            app.FcKnobLabel = uilabel(app.Panel_carrier);
            app.FcKnobLabel.HorizontalAlignment = 'center';
            app.FcKnobLabel.Position = [96 212 25 22];
            app.FcKnobLabel.Text = 'Fc';

            % Create Knob_carrier_freq
            app.Knob_carrier_freq = uiknob(app.Panel_carrier, 'continuous');
            app.Knob_carrier_freq.Limits = [0 10];
            app.Knob_carrier_freq.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.Knob_carrier_freq.Position = [60 94 88 88];

            % Create DropDown_2Label
            app.DropDown_2Label = uilabel(app.Panel_carrier);
            app.DropDown_2Label.HorizontalAlignment = 'right';
            app.DropDown_2Label.FontName = 'Bookman';
            app.DropDown_2Label.Position = [32 22 25 22];
            app.DropDown_2Label.Text = '*';

            % Create DropDown_carrier_mul
            app.DropDown_carrier_mul = uidropdown(app.Panel_carrier);
            app.DropDown_carrier_mul.Items = {'10', '100', '1000'};
            app.DropDown_carrier_mul.ItemsData = [10 100 1000];
            app.DropDown_carrier_mul.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.DropDown_carrier_mul.FontName = 'Bookman';
            app.DropDown_carrier_mul.ClickedFcn = createCallbackFcn(app, @valueChanged, true);
            app.DropDown_carrier_mul.Position = [72 22 71 22];
            app.DropDown_carrier_mul.Value = 10;

            % Create Panel_mod
            app.Panel_mod = uipanel(app.Tab_fm);
            app.Panel_mod.AutoResizeChildren = 'off';
            app.Panel_mod.BorderColor = [0.8 0.8 0.8];
            app.Panel_mod.ForegroundColor = [1 1 1];
            app.Panel_mod.BorderWidth = 0.5;
            app.Panel_mod.Title = '             Modülatör';
            app.Panel_mod.BackgroundColor = [0 0.4471 0.7412];
            app.Panel_mod.FontName = 'Bookman';
            app.Panel_mod.FontWeight = 'bold';
            app.Panel_mod.FontSize = 16;
            app.Panel_mod.Position = [271 145 210 365];

            % Create Slider_mod_amp
            app.Slider_mod_amp = uislider(app.Panel_mod);
            app.Slider_mod_amp.Limits = [0 10];
            app.Slider_mod_amp.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.Slider_mod_amp.Position = [31 289 149 3];

            % Create DLabel
            app.DLabel = uilabel(app.Panel_mod);
            app.DLabel.HorizontalAlignment = 'right';
            app.DLabel.Position = [84 302 25 22];
            app.DLabel.Text = 'D';

            % Create FmKnob_2Label
            app.FmKnob_2Label = uilabel(app.Panel_mod);
            app.FmKnob_2Label.HorizontalAlignment = 'center';
            app.FmKnob_2Label.Position = [88 212 25 22];
            app.FmKnob_2Label.Text = 'Fm';

            % Create Knob_mod_freq
            app.Knob_mod_freq = uiknob(app.Panel_mod, 'continuous');
            app.Knob_mod_freq.Limits = [0 10];
            app.Knob_mod_freq.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.Knob_mod_freq.Position = [55 93 90 90];

            % Create Label
            app.Label = uilabel(app.Panel_mod);
            app.Label.HorizontalAlignment = 'right';
            app.Label.FontName = 'Bookman';
            app.Label.Position = [26 22 25 22];
            app.Label.Text = '*';

            % Create DropDown_mod_mul
            app.DropDown_mod_mul = uidropdown(app.Panel_mod);
            app.DropDown_mod_mul.Items = {'10', '100', '1000'};
            app.DropDown_mod_mul.ItemsData = [10 100 1000];
            app.DropDown_mod_mul.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.DropDown_mod_mul.FontName = 'Bookman';
            app.DropDown_mod_mul.ClickedFcn = createCallbackFcn(app, @valueChanged, true);
            app.DropDown_mod_mul.Position = [66 22 71 22];
            app.DropDown_mod_mul.Value = 10;

            % Create Button_play_fmtab
            app.Button_play_fmtab = uibutton(app.Tab_fm, 'push');
            app.Button_play_fmtab.ButtonPushedFcn = createCallbackFcn(app, @Button_play_fmtabPushed, true);
            app.Button_play_fmtab.BackgroundColor = [0.851 0.3255 0.098];
            app.Button_play_fmtab.FontName = 'Bookman';
            app.Button_play_fmtab.FontSize = 18;
            app.Button_play_fmtab.FontWeight = 'bold';
            app.Button_play_fmtab.FontColor = [1 1 1];
            app.Button_play_fmtab.Position = [188 74 127 43];
            app.Button_play_fmtab.Text = 'Çal';

            % Create Title
            app.Title = uilabel(app.Tab_fm);
            app.Title.HorizontalAlignment = 'center';
            app.Title.FontName = 'Bookman';
            app.Title.FontSize = 30;
            app.Title.FontWeight = 'bold';
            app.Title.FontColor = [0.149 0.149 0.149];
            app.Title.Position = [378 884 511 71];
            app.Title.Text = 'Frekans Modülasyon Sentezi';

            % Create Image_diagram
            app.Image_diagram = uiimage(app.Tab_fm);
            app.Image_diagram.Position = [42 541 351 345];
            app.Image_diagram.ImageSource = fullfile(pathToMLAPP, 'fm.png');

            % Create Tab_example
            app.Tab_example = uitab(app.TabGroup);
            app.Tab_example.AutoResizeChildren = 'off';
            app.Tab_example.Title = 'Örnek';
            app.Tab_example.BackgroundColor = [1 1 1];
            app.Tab_example.ForegroundColor = [0 0.4471 0.7412];

            % Create UIAxes_Gong
            app.UIAxes_Gong = uiaxes(app.Tab_example);
            title(app.UIAxes_Gong, 'FM Ses (Sound) Dalga Şekli')
            xlabel(app.UIAxes_Gong, 'Zaman')
            ylabel(app.UIAxes_Gong, 'Genlik')
            zlabel(app.UIAxes_Gong, 'Z')
            app.UIAxes_Gong.Position = [450 34 399 223];

            % Create UIAxes_Envelope
            app.UIAxes_Envelope = uiaxes(app.Tab_example);
            title(app.UIAxes_Envelope, 'Zarf (Envelope ) Grafiği')
            xlabel(app.UIAxes_Envelope, 'Zaman')
            ylabel(app.UIAxes_Envelope, 'Genlik')
            zlabel(app.UIAxes_Envelope, 'Z')
            app.UIAxes_Envelope.Position = [452 287 399 223];

            % Create Image_gong
            app.Image_gong = uiimage(app.Tab_example);
            app.Image_gong.Position = [592 847 102 80];
            app.Image_gong.ImageSource = fullfile(pathToMLAPP, 'Screenshot 2023-05-04 185723.png');

            % Create Button_play_ex_tab
            app.Button_play_ex_tab = uibutton(app.Tab_example, 'push');
            app.Button_play_ex_tab.ButtonPushedFcn = createCallbackFcn(app, @Button_play_ex_tabPushed, true);
            app.Button_play_ex_tab.BackgroundColor = [0.851 0.3255 0.098];
            app.Button_play_ex_tab.FontName = 'Bookman';
            app.Button_play_ex_tab.FontSize = 24;
            app.Button_play_ex_tab.FontWeight = 'bold';
            app.Button_play_ex_tab.FontColor = [1 1 1];
            app.Button_play_ex_tab.Position = [670 555 176 54];
            app.Button_play_ex_tab.Text = 'Çal';

            % Create Image_gong_wave_1
            app.Image_gong_wave_1 = uiimage(app.Tab_example);
            app.Image_gong_wave_1.Position = [371 683 262 139];
            app.Image_gong_wave_1.ImageSource = fullfile(pathToMLAPP, 'Screenshot 2023-05-04 185217.png');

            % Create Image_gong_wave_2
            app.Image_gong_wave_2 = uiimage(app.Tab_example);
            app.Image_gong_wave_2.Position = [656 684 270 138];
            app.Image_gong_wave_2.ImageSource = fullfile(pathToMLAPP, 'Screenshot 2023-05-04 185454.png');

            % Create Switch_noise
            app.Switch_noise = uiswitch(app.Tab_example, 'slider');
            app.Switch_noise.ItemsData = [false true];
            app.Switch_noise.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.Switch_noise.FontName = 'Bookman';
            app.Switch_noise.FontWeight = 'bold';
            app.Switch_noise.Position = [538 579 36 16];
            app.Switch_noise.Value = false;

            % Create NoiseamplitudeSpinnerLabel
            app.NoiseamplitudeSpinnerLabel = uilabel(app.Tab_example);
            app.NoiseamplitudeSpinnerLabel.HorizontalAlignment = 'right';
            app.NoiseamplitudeSpinnerLabel.FontName = 'Bookman';
            app.NoiseamplitudeSpinnerLabel.FontWeight = 'bold';
            app.NoiseamplitudeSpinnerLabel.FontColor = [0.6353 0.0784 0.1843];
            app.NoiseamplitudeSpinnerLabel.Position = [409 595 98 22];
            app.NoiseamplitudeSpinnerLabel.Text = 'Noise amplitude';

            % Create Spinner_noise_amp
            app.Spinner_noise_amp = uispinner(app.Tab_example);
            app.Spinner_noise_amp.Step = 0.01;
            app.Spinner_noise_amp.ValueChangedFcn = createCallbackFcn(app, @valueChanged, true);
            app.Spinner_noise_amp.Position = [410 573 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = fm_project

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end