%%% Bu fonksiyonda keyboard'dan gelen inputlar kayit ediliyor. Stimulus
%%% onset ve response time disinda belirtilmesi gereken bir diger degisken
%%% de "RegisteryMarker". Bu degisken kodun icindeki "for" ya da "while"
%%% gibi tekrar eden dongulerin kacinci dongude oldugunu anlayabilmek icin
%%% olusturdugumuz variable. Stimulus'unuzu gosterdiginiz loop'tan hemen once
%%% RegisteryMarker=0, gibi bir degisken acip, her loop'ta
%%% RegisteryMarker=RegisteryMarker+1 yapmaniz gerekiyor. Daha once dendigi
%%% gibi bunun sebebi her loop'ta degeri 1 yukselen bir degisken yaratmak.
%%% Bunun sayesinde EXCEL dosyalarina girdi Indexlemek gibi islemler cok
%%% kolaylasiyor. Ayrica kacinci response'ta ya da stimulus
%%% presentation'inda oldugunuz gibi onemli bilgileri de bu sekilde
%%% ogrenebilirsiniz. Bir ornek icin "Functionalized_MSP_Aging_SourceCode"
%%% script'indeki stimulus dongulerine bakabilirsiniz. Bu markerin o
%%% scriptteki adi "sheetmarker". Bunun sebebi de o script'te Excel
%%% sheet'ine yapilacak kayitlarin bu markerla indexlenip islenmesiydi. 


function KeyboardReg(KeyPressMarker,TrialStartMarker,RegisteryMarker,StimPresentTime,paradigm)       %%% "KeypressMarker"   = Obtained from KbQueue or KbCheck-time of key press / 
                                                                                                     %%% "TrialStartMarker" = Obtained from timers within the paradigm script / Specify the beginning time of the trial
                                                                                                     %%% "RegisteryMarker"  = Iteration markers within paradigm script.
                                                                                                     %%% "StimPresentTime"  = Required in paradigms where Reactiontime calculation is possible. This is the time stamp of stimulus presentation. It is required for reaction time measurements. Put empty "[]" there is no RT calculation.
                                                                                                     %%% "paradigm"         = Specifies paradigm with numbers. 0=Reaction Time paradigms, 1=Multistable / This is used because multistable paradigms do not include Reaction Time variable. If you set 0, it will calculate reaction time according to last stimulus presentation.

KeyPressMarker(find(KeyPressMarker==0))=NaN;  %#ok<FNDSB>
                                            
KeyPressTime_V=KeyPressMarker-TrialStartMarker;        %%% Creates a vector out of subtraction of Trial Beginning from constant time values of all keyboard presses. In short, it is the reaction time values of all possible keyboard presses within a trial. 

KeyPressTime=KeyPressTime_V(KeyPressTime_V>0.05);      %%% Reaction time values that are above 50 ms. 

[endtime, keyIndex]=min(KeyPressMarker);               

Key_Code=KbName(keyIndex); 

RegisteryMarker=RegisteryMarker+1;

if paradigm==0
    
    ReactionTime=min(KeyPressMarker)-StimPresentTime;
    
    assignin('base','ReactionTime',ReactionTime);
    
end


assignin('base','sheetmarker',RegisteryMarker);
assignin('base','KeyIndex',keyIndex);
assignin('base','Key_Code',Key_Code);
assignin('base','PressTime',min(KeyPressTime));

end