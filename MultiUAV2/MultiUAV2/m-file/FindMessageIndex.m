function [MessageIndex] = FindMessageIndex(CommunicationsMemory,MessageTitle)
%FindMessageIndex - uses input for retrive the index of a message in the global communications memory.
%
%  Inputs:
%     CommunicationsMemory - the communications structure that the message belong to.
%     MessageTitle - a Message ID or a Message Title.
%  Outputs:
%     MessageIndex - index of the message.
%  AFRL/VACA
%  April 2003 - Created and Debugged - RAS
%  March 2004 - Created and Debugged - RAS


NumberMessages = CommunicationsMemory.NumberMessages;

MessageIndex = 0;	% default to an illegal value for index
for (CountMessages = 1:NumberMessages),
	if(strcmp(CommunicationsMemory.Messages{CountMessages}.Title,MessageTitle)),
		MessageIndex = CountMessages;
		break;
	end;
end;
