function [sys,x0,str,ts] = SendMessageS(t,x,InputVector,flag,CommunicationsMemory,MessageID,ReuseMatrix)
%SendMessageS - saves communication messages in the global communications memory and updates global in-boxes.
%
%  Parameters:
%    ReuseMatrix - set equal to 'growing' to dynamically size the data matricies. Set equal to 'static' to limit the size of the messages data matrix.
%          NOTE: ObjectID is being used as the index into the limited size matrix
%  Outputs:

%  AFRL/VACA
%  April 2003 - Created and Debugged - RAS
%  July 2003 - Change the way messages and headers are added to their arrays
%  March 2004 - made communication memory an input argument.

% NOTE: Messages are added to the message ques in columns. This makes programming in the associated c++ code easier.
global g_Debug; if(g_Debug==1),disp('SendMessageS.m');end; 


if(strcmp(CommunicationsMemory,'g_CommunicationMemory')),
    
    global g_SampleTime;
    global g_EnableVehicle;
    global g_CommunicationMemory;
    global g_ObjectMessageIDs;
   
    switch flag,
        
    case 0,
        sizes = simsizes;
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs = 0;
        % ObjectID
        sizes.NumInputs = -1;
        sizes.DirFeedthrough = 1;
        sizes.NumSampleTimes = 1;   % at least one sample time is needed
        sys = simsizes(sizes);
        x0  = [];
        str = [];
        ts  = [g_SampleTime];
        
    case 1,
        sys = [];
        
    case 2,
        sys = [];
        
    case 3,
        sys = [];
        ObjectID = InputVector(1);
        if(ObjectID <= 0),	% object ID
            return;
        end;
        NumberInputs = size(InputVector,1);
        NumberEntriesRequired = 0;
        Success = 0;
        if(MessageID > 0),
            if(g_CommunicationMemory.Messages{MessageID}.Enabled),
                NumberEntriesRequired = g_CommunicationMemory.Messages{MessageID}.NumberEntries + 2;
                if(NumberEntriesRequired <= NumberInputs),
                    if(strcmp(ReuseMatrix,'growing')),
                        g_CommunicationMemory.Messages{MessageID}.LastMessageIndex = g_CommunicationMemory.Messages{MessageID}.LastMessageIndex + 1;
                        %check to see if need to preallocate more rows to the data matrix
                        if(g_CommunicationMemory.Messages{MessageID}.LastMessageIndex > g_CommunicationMemory.Messages{MessageID}.TotalNumberMessagesAllocated),
                            g_CommunicationMemory.MemoryAllocationMetric(MessageID) = g_CommunicationMemory.MemoryAllocationMetric(MessageID) + 1;
                            g_CommunicationMemory.Messages{MessageID}.TotalNumberMessagesAllocated = g_CommunicationMemory.Messages{MessageID}.TotalNumberMessagesAllocated + ...
                                g_CommunicationMemory.Messages{MessageID}.SizeToPreAllocate;
                            g_CommunicationMemory.Messages{MessageID}.Data = ...
                                [g_CommunicationMemory.Messages{MessageID}.Data, ...
                                    zeros(g_CommunicationMemory.Messages{MessageID}.NumberEntries+2,g_CommunicationMemory.Messages{MessageID}.SizeToPreAllocate)];
                        end;
                    else,	%if(strcmp(ReuseMatrix,'Growing'))
                        if(size(g_CommunicationMemory.Messages{MessageID}.Data,2) < g_CommunicationMemory.Messages{MessageID}.NumberSenders),
                            g_CommunicationMemory.Messages{MessageID}.TotalNumberMessagesAllocated = g_CommunicationMemory.Messages{MessageID}.NumberSenders;
                            if(~isempty(g_CommunicationMemory.Messages{MessageID}.DefaultMessage)),
                                g_CommunicationMemory.Messages{MessageID}.Data = g_CommunicationMemory.Messages{MessageID}.DefaultMessage * ones(1,g_CommunicationMemory.Messages{MessageID}.NumberSenders);
                            else,       %if(~isempty(g_CommunicationMemory.Messages{MessageID}.DefaultMessage)),
                                g_CommunicationMemory.Messages{MessageID}.Data = zeros(g_CommunicationMemory.Messages{MessageID}.NumberEntries+2,g_CommunicationMemory.Messages{MessageID}.NumberSenders);
                            end;       %if(~isempty(g_CommunicationMemory.Messages{MessageID}.DefaultMessage)),
                        end;
                        g_CommunicationMemory.Messages{MessageID}.LastMessageIndex = ObjectID;
                    end;	%if(strcmp(ReuseMatrix,'Growing'))
                    %store message in the communications structure
                    g_CommunicationMemory.Messages{MessageID}.Data(:,g_CommunicationMemory.Messages{MessageID}.LastMessageIndex) =  InputVector([1:NumberEntriesRequired]);
                    MessageEvaluated = 0;
                    %put message headers into the inboxes
                    Recipients = [];
                    NumberInBoxes = size(g_CommunicationMemory.InBoxes,1);
                    if(NumberInputs > NumberEntriesRequired),	% +1 accounts for ID
                        RecipientIDs = InputVector([(NumberEntriesRequired + 1):end]);
                        for(CountIDs = 1:length(RecipientIDs)),
                            [ObjectType,ObjectIndex] = ObjectIDToTypeIndex(RecipientIDs(CountIDs));
                            Recipients = [Recipients ObjectIndex];
                         if(~isempty(ObjectType) & (g_ObjectMessageIDs.AllVehiclesType==ObjectType))
                            Recipients = [Recipients [(g_ObjectMessageIDs.VehicleIDFirst):(g_ObjectMessageIDs.VehicleIDLast)]];    
                        end;
                         if(~isempty(ObjectType) & (g_ObjectMessageIDs.AllTargetsType==ObjectType))
                            Recipients = [Recipients [(g_ObjectMessageIDs.TargetIDFirst):(g_ObjectMessageIDs.TargetIDLast)]];    
                        end;
                       end; %for(CountIDs = 1:length(RecipientIDs)),
                        Recipients = unique(Recipients);
                        Recipients = Recipients(find(Recipients>0));
                    else,	%if(NumberInputs > NumberEntriesRequired),
                        Recipients = [1:NumberInBoxes];
                    end;	%if(NumberInputs > NumberEntriesRequired),
                    NumberRecipients = length(Recipients);
                    for(CountRecipients = [1:NumberRecipients]),
                        CountInBoxes = Recipients(CountRecipients);
                        if(CountInBoxes > NumberInBoxes),
                            continue;
                        end;
                        g_CommunicationMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex = g_CommunicationMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex + 1;
                        if(g_CommunicationMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex > g_CommunicationMemory.InBoxes(CountInBoxes).TotalNumberMessageHeadersAllocated),
                            g_CommunicationMemory.InBoxAllocationMetric(CountInBoxes) = g_CommunicationMemory.InBoxAllocationMetric(CountInBoxes) + 1;
                            g_CommunicationMemory.InBoxes(CountInBoxes).TotalNumberMessageHeadersAllocated = ...
                                g_CommunicationMemory.InBoxes(CountInBoxes).TotalNumberMessageHeadersAllocated + ...																					
                                g_CommunicationMemory.InBoxes(CountInBoxes).SizeToPreAllocate;
                            g_CommunicationMemory.InBoxes(CountInBoxes).MessageHeaders = ...
                                [g_CommunicationMemory.InBoxes(CountInBoxes).MessageHeaders, ...
                                    zeros(g_CommunicationMemory.InBoxes(CountInBoxes).NumberEntries,g_CommunicationMemory.InBoxes(CountInBoxes).SizeToPreAllocate)];
                        end;
                        TimeActivate = t + g_CommunicationMemory.DelayMatrix(ObjectID,CountInBoxes) + g_CommunicationMemory.Messages{MessageID}.MessageDelay;
                        g_CommunicationMemory.InBoxes(CountInBoxes).MessageHeaders(:,g_CommunicationMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex) = ...
                            [t,TimeActivate,MessageID,g_CommunicationMemory.Messages{MessageID}.LastMessageIndex,MessageEvaluated]';
                    end;
                else,	%if(NumberEntriesRequired == NumberInputs),
                    DisplayString = sprintf('ERROR(SendMessageS): Wrong number of entries for message #%d (%s). Number entries given: %d, Number entries required: %d', ...
                        MessageID,g_CommunicationMemory.Messages{MessageID}.Title,NumberInputs,NumberEntriesRequired);
                    disp(DisplayString);
                end;	%if(NumberEntriesRequired == NumberInputs),
            else,   %if(g_CommunicationMemory.Messages{MessageID}.Enabled),
                
                
                
            end;   %if(g_CommunicationMemory.Messages{MessageID}.Enabled),
        else,	%if(MessageIndex > 0),
            DisplayString = sprintf('ERROR(SendMessageS): Unknown message ID (%d)',MessageID);
            disp(DisplayString);
            return;
        end;	%if(MessageIndex > 0),
        
        
    case 4,
        sys = [];
        
    case 9,
        sys = [];
        
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);
        
    end;
    
elseif(strcmp(CommunicationsMemory,'g_TruthMemory')),			%if(strcmp(CommunicationsMemory,'g_CommunicationMemory')),
    
    global g_SampleTime;
    global MaxNumberVehicles;
    global g_TruthMemory;
    global g_ObjectMessageIDs;
    
    
    switch flag,
        
    case 0,
        sizes = simsizes;
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs = 0;
        % ObjectID
        sizes.NumInputs = -1;
        sizes.DirFeedthrough = 1;
        sizes.NumSampleTimes = 1;   % at least one sample time is needed
        sys = simsizes(sizes);
        x0  = [];
        str = [];
        ts  = [g_SampleTime];
        
    case 1,
        sys = [];
        
    case 2,
        sys = [];
        
    case 3,
        sys = [];
        ObjectID = InputVector(1);
        if(ObjectID <= 0),	% vehicle ID
            return;
        end;
        NumberInputs = size(InputVector,1);
        NumberEntriesRequired = 0;
        Success = 0;
        if(MessageID > 0),
            NumberEntriesRequired = g_TruthMemory.Messages{MessageID}.NumberEntries + 2;
            if(NumberEntriesRequired <= NumberInputs),
                if(strcmp(ReuseMatrix,'growing')),
                    g_TruthMemory.Messages{MessageID}.LastMessageIndex = g_TruthMemory.Messages{MessageID}.LastMessageIndex + 1;
                    %check to see if need to preallocate more rows to the data matrix
                    if(g_TruthMemory.Messages{MessageID}.LastMessageIndex > g_TruthMemory.Messages{MessageID}.TotalNumberMessagesAllocated),
                        g_TruthMemory.MemoryAllocationMetric(MessageID) = g_TruthMemory.MemoryAllocationMetric(MessageID) + 1;
                        g_TruthMemory.Messages{MessageID}.TotalNumberMessagesAllocated = g_TruthMemory.Messages{MessageID}.TotalNumberMessagesAllocated + ...
                            g_TruthMemory.Messages{MessageID}.SizeToPreAllocate;
                        g_TruthMemory.Messages{MessageID}.Data = ...
                            [g_TruthMemory.Messages{MessageID}.Data, ...
                                zeros(g_TruthMemory.Messages{MessageID}.NumberEntries+2,g_TruthMemory.Messages{MessageID}.SizeToPreAllocate)];
                    end;
                else,	%if(strcmp(ReuseMatrix,'Growing')),
                    if(size(g_TruthMemory.Messages{MessageID}.Data,2) < g_TruthMemory.Messages{MessageID}.NumberSenders),
                        g_TruthMemory.Messages{MessageID}.TotalNumberMessagesAllocated = g_TruthMemory.Messages{MessageID}.NumberSenders;
                            if(~isempty(g_TruthMemory.Messages{MessageID}.DefaultMessage)),
                                g_TruthMemory.Messages{MessageID}.Data = g_TruthMemory.Messages{MessageID}.DefaultMessage * ones(1,g_TruthMemory.Messages{MessageID}.NumberSenders);
                            else,       %if(~isempty(g_CommunicationMemory.Messages{MessageID}.DefaultMessage)),
                                g_TruthMemory.Messages{MessageID}.Data = zeros(g_TruthMemory.Messages{MessageID}.NumberEntries+2,g_TruthMemory.Messages{MessageID}.NumberSenders);
                            end;       %if(~isempty(g_CommunicationMemory.Messages{MessageID}.DefaultMessage)),
                    end;
                    g_TruthMemory.Messages{MessageID}.LastMessageIndex = ObjectID;
                end;	%if(strcmp(ReuseMatrix,'Growing')),
                %store message in the communications structure
                g_TruthMemory.Messages{MessageID}.Data(:,g_TruthMemory.Messages{MessageID}.LastMessageIndex) = InputVector([1:NumberEntriesRequired]);
                MessageEvaluated = 0;
                %put message headers into the inboxes
                Recipients = [];
                NumberInBoxes = size(g_TruthMemory.InBoxes,1);
                if(NumberInputs > NumberEntriesRequired),	% +1 accounts for ID
                        RecipientIDs = InputVector([(NumberEntriesRequired + 1):end]);
                        for(CountIDs = 1:length(RecipientIDs)),
                            [ObjectType,ObjectIndex] = ObjectIDToTypeIndex(RecipientIDs(CountIDs));
                            Recipients = [Recipients ObjectIndex];
                         if(~isempty(ObjectType) & (g_ObjectMessageIDs.AllVehiclesType==ObjectType))
                            Recipients = [Recipients [(g_ObjectMessageIDs.VehicleIDFirst):(g_ObjectMessageIDs.VehicleIDLast)]];    
                        end;
                         if(~isempty(ObjectType) & (g_ObjectMessageIDs.AllTargetsType==ObjectType))
                            Recipients = [Recipients [(g_ObjectMessageIDs.TargetIDFirst):(g_ObjectMessageIDs.TargetIDLast)]];    
                        end;
                       end; %for(CountIDs = 1:length(RecipientIDs)),
                        Recipients = unique(Recipients);
                        Recipients = Recipients(find(Recipients>0));
                else,	%if(NumberInputs > NumberEntriesRequired),
                    Recipients = [1:NumberInBoxes];
                end;	%if(NumberInputs > NumberEntriesRequired),
                NumberRecipients = length(Recipients);
                for(CountRecipients = [1:NumberRecipients]),
                    CountInBoxes = Recipients(CountRecipients);
                    if(CountInBoxes > NumberInBoxes),
                        continue;
                    end;
                    g_TruthMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex = g_TruthMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex + 1;
                    if(g_TruthMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex > g_TruthMemory.InBoxes(CountInBoxes).TotalNumberMessageHeadersAllocated),
                        g_TruthMemory.InBoxAllocationMetric(CountInBoxes) = g_TruthMemory.InBoxAllocationMetric(CountInBoxes) + 1;
                        g_TruthMemory.InBoxes(CountInBoxes).TotalNumberMessageHeadersAllocated = ...
                            g_TruthMemory.InBoxes(CountInBoxes).TotalNumberMessageHeadersAllocated + ...																					
                            g_TruthMemory.InBoxes(CountInBoxes).SizeToPreAllocate;
                        g_TruthMemory.InBoxes(CountInBoxes).MessageHeaders = ...
                            [g_TruthMemory.InBoxes(CountInBoxes).MessageHeaders, ...
                                zeros(g_TruthMemory.InBoxes(CountInBoxes).NumberEntries,g_TruthMemory.InBoxes(CountInBoxes).SizeToPreAllocate)];
                    end;
                    TimeActivate = t + g_TruthMemory.DelayMatrix(ObjectID,CountInBoxes) + g_TruthMemory.Messages{MessageID}.MessageDelay;
                    g_TruthMemory.InBoxes(CountInBoxes).MessageHeaders(:,g_TruthMemory.InBoxes(CountInBoxes).LastMessageHeaderIndex) = ...
                        [t,TimeActivate,MessageID,g_TruthMemory.Messages{MessageID}.LastMessageIndex,MessageEvaluated]';
                end;
            else,	%if(NumberEntriesRequired == NumberInputs),
                DisplayString = sprintf('ERROR(SendMessageS): Wrong number of entries for message #%d (%s). Number entries given: %d, Number entries required: %d', ...
                    MessageID,g_TruthMemory.Messages{MessageID}.Title,NumberInputs,NumberEntriesRequired);
                disp(DisplayString);
            end;	%if(NumberEntriesRequired == NumberInputs),
        else,	%if(MessageIndex > 0),
            DisplayString = sprintf('ERROR(SendMessageS): Unknown message ID (%d)',MessageID);
            disp(DisplayString);
            return;
        end;	%if(MessageIndex > 0),
        
        
    case 4,
        sys = [];
        
    case 9,
        sys = [];
        
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);
        
    end;
    
else,			%if(strcmp(CommunicationsMemory,'g_TruthMemory')),
    error(['Unhandled flag = ',CommunicationsMemory]);
    
    
end;			%if(strcmp(CommunicationsMemory,'g_TruthMemory')),





return; %




function [ObjectType,ObjectIndex] = ObjectIDToTypeIndex(ObjectID)
% calculate the ID Index given an ObjectID
global g_ObjectMessageIDs;

ObjectType = round(ObjectID/g_ObjectMessageIDs.TypeMultiplier);
if((ObjectType>=1)&(ObjectType<=g_ObjectMessageIDs.NumberTypes))
    ObjectIndex = mod(ObjectID,round(ObjectType*g_ObjectMessageIDs.TypeMultiplier));
else,
    ObjectIndex = -1;
end;
 if((ObjectType==g_ObjectMessageIDs.AllVehiclesType)|(ObjectType==g_ObjectMessageIDs.AllTargetsType))
    ObjectIndex = -1;
end;
        
return;     %ObjectIDToIndex