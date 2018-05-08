classdef Lithology
   properties
       lithology
   end
   
   methods
       %%
       function obj = Lithology(lithologyGroupNodes)
            if exist('lithologyGroupNodes','var') == true
                obj.lithology = obj.analyzeLithologyGroupNodes(lithologyGroupNodes);  
            end 
       end
       
       %% Main Start
       function lithologyAll = analyzeLithologyGroupNodes(obj, lithologyGroupMainNodes)
           nLithologyGroupMainNodes = lithologyGroupMainNodes.getLength;
           lithologyAll = {};
           for i=0:nLithologyGroupMainNodes-1
               lithologyGroupNodeMain = lithologyGroupMainNodes.item(i);
               lithologyGroupMain = obj.analyzeLithologyGroupNodeMain(lithologyGroupNodeMain);
               lithologyAll = [lithologyAll; lithologyGroupMain];
           end
       end
       
       %% Main Analysis
       function lithologyGroupMain = analyzeLithologyGroupNodeMain(obj, lithologyGroupNodeMain)
          id   = char(lithologyGroupNodeMain.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(lithologyGroupNodeMain.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyGroupNodeMain.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId   = char(lithologyGroupNodeMain.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);

          lithologyGroupSubNodes = lithologyGroupNodeMain.getElementsByTagName('LithologyGroup');
          nLithologyGroupSubNodes = lithologyGroupSubNodes.getLength;
          
          lithologyGroupMain = {};
          lithologyGroupSubRows = {};
          for i=0:nLithologyGroupSubNodes-1               
               lithologyGroupNodeSub = lithologyGroupSubNodes.item(i);
               lithologyGroupSub = obj.analyzeLithologyGroupNodeSub(lithologyGroupNodeSub);
               
               nRows = size(lithologyGroupSub,1);
               ids   = repmat({id},nRows,1);
               names = repmat({name}, nRows,1);
               readOnlys = repmat({readOnly}, nRows,1);
               petroModIds = repmat({petroModId}, nRows, 1);
               lithologyGroupSubMatrix = [ids, names, readOnlys, petroModIds, lithologyGroupSub];
               lithologyGroupSubRows = [lithologyGroupSubRows; lithologyGroupSubMatrix];
          end
               lithologyGroupMain = [lithologyGroupMain; lithologyGroupSubRows];

       end
       
       %% Subs
       function lithologyGroupSub = analyzeLithologyGroupNodeSub(obj, lithologyGroupNodeSub)
          id   = char(lithologyGroupNodeSub.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(lithologyGroupNodeSub.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyGroupNodeSub.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId   = char(lithologyGroupNodeSub.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);

          lithologyNodes = lithologyGroupNodeSub.getElementsByTagName('Lithology');
          nLithologyGroupSubNodes = lithologyNodes.getLength;
          
          lithologyRow = {};
          lithologyGroupSub = {};
          for i=0:nLithologyGroupSubNodes-1
               lithologyNode = lithologyNodes.item(i);
               lithology = obj.analyzeLithologyNode(lithologyNode);
               lithologyRows(i+1,:) = [id, name, readOnly, petroModId, lithology];
          end
          lithologyGroupSub = [lithologyGroupSub; lithologyRows];

       end
       
      %% 
      function lithology = analyzeLithologyNode(obj, lithologyNode)

          id         = char(lithologyNode.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name       = char(lithologyNode.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyNode.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId = char(lithologyNode.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);
          pattern = char(lithologyNode.getElementsByTagName('Pattern').item(0).getFirstChild.getData);
          color      = char(lithologyNode.getElementsByTagName('Color').item(0).getFirstChild.getData);

          parameterGroupNodes = lithologyNode.getElementsByTagName('ParameterGroup');
          nPrameterGroups = parameterGroupNodes.getLength;
          parameterGroup = {};
          
          for i = 0:nPrameterGroups-1
             parameterGroupNode = parameterGroupNodes.item(i);
             parameterGroupRow  = obj.analyzeParameterGroup(parameterGroupNode);
             parameterGroup     = [parameterGroup; parameterGroupRow];
          end
          lithology = {id, name, readOnly, petroModId, pattern, color, parameterGroup};
      end       
       %%
       function [parameterGroup] = analyzeParameterGroup(obj, parameterGroupNode)
          id = char(parameterGroupNode.getElementsByTagName('MetaParameterGroupId').item(0).getFirstChild.getData);

          parameterNodes = parameterGroupNode.getElementsByTagName('Parameter');
          nPrameters = parameterNodes.getLength;
         
          parameterGroup = {};   
          for i = 0:nPrameters-1
              parameterNode =  parameterNodes.item(i);
              parameter = obj.analyzeParameter(parameterNode);
              parameterGroupRow = {id, parameter{1}, parameter{2}};
              parameterGroup = [parameterGroup; parameterGroupRow];
          end
       end
       
       %%
       function [parameter] = analyzeParameter(obj, parameterNode)
           id = char(parameterNode.getElementsByTagName('MetaParameterId').item(0).getFirstChild.getData); 
           value = char(parameterNode.getElementsByTagName('Value').item(0).getFirstChild.getData);
           parameter = {id, value};
       end
       
   end
    
 %% Get methods
 methods

 end
    
end