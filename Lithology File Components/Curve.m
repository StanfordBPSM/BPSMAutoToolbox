classdef Curve
   properties(SetAccess = public)
       curveGroupTitles = {'Id', 'Name', 'ReadOnly'}
       curveTitles = {'Id', 'Name', 'ReadOnly', 'PetrelTemplateX', 'PetrelTemplateY', 'PetroModUnitX', 'PetroModUnitY', 'PetroModId', 'CurvePoints'};
       curvePointTitles = {'X', 'Y'}
       curveGroups
   end
   
   methods
       function obj = Curve(curveGroupNodes)
            if exist('curveGroupNodes','var') == true
                obj.curveGroups = obj.analyzeCurveGroupNodes(curveGroupNodes);  
            end
       end
       
       % =========================================================   
       function curveGroups = analyzeCurveGroupNodes(obj, curveGroupNodes)
           nCurveGroups = curveGroupNodes.getLength;
           curveGroups = {};
           for i=0:nCurveGroups-1
               curveGroupNode = curveGroupNodes.item(i);
               curveGroup = obj.analyzeCurveGroupNode(curveGroupNode);
               curveGroups = [curveGroups; curveGroup];
           end
       end
       
       % =========================================================   
       function curveGroup = analyzeCurveGroupNode(obj, curveGroupNode)
          id   = char(curveGroupNode.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(curveGroupNode.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(curveGroupNode.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          
          curveNodes = curveGroupNode.getElementsByTagName('Curve');
          nCurveNodes = curveNodes.getLength;
          
          curveGroup = {};
          if nCurveNodes > 0
             for i = 0:nCurveNodes-1
                 curveNode     = curveNodes.item(i);
                 curve         = obj.analyzeCurve(curveNode);
                 curveGroupRow = [id, name, readOnly, curve];
                 curveGroup    = [curveGroup; curveGroupRow];
             end
          else
                curve = {'', '', '', '', '', '', '', '', ''};
                curveGroupRow = [id, name, readOnly, curve];
                curveGroup    = [curveGroup; curveGroupRow];
          end
       end
       
       % =========================================================   
       function curve = analyzeCurve(obj, curveNode)
          id                = char(curveNode.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name              = char(curveNode.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly          = char(curveNode.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petrelTemplateX   = char(curveNode.getElementsByTagName('PetrelTemplateX').item(0).getFirstChild.getData);
          petrelTemplateY   = char(curveNode.getElementsByTagName('PetrelTemplateY').item(0).getFirstChild.getData);
          petroModUnitX     = char(curveNode.getElementsByTagName('PetroModUnitX').item(0).getFirstChild.getData);
          petroModUnitY     = char(curveNode.getElementsByTagName('PetroModUnitY').item(0).getFirstChild.getData);
          petroModId        = char(curveNode.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);       
          curvePointNodes   = curveNode.getElementsByTagName('CurvePoint');
          nCurvePointNodes  = curvePointNodes.getLength;
          
          curvePoints = {};
          if nCurvePointNodes>0
             for i = 0:nCurvePointNodes-1
                 curvePointNode = curvePointNodes.item(i);
                 curvePoint = obj.analyzeCurvePoint(curvePointNode);
                 curvePoints = [curvePoints; curvePoint];
             end
          else
              curvePoints = '';
          end
          
          curve = {id, name, readOnly, petrelTemplateX, petrelTemplateY, petroModUnitX, petroModUnitY, petroModId, curvePoints};
           
       end
       
       % =========================================================   
       function curvePoint = analyzeCurvePoint(obj, curvePointNode)
             x   = char(curvePointNode.getElementsByTagName('X').item(0).getFirstChild.getData);
             y   = char(curvePointNode.getElementsByTagName('Y').item(0).getFirstChild.getData);
             curvePoint = {x, y};
       end
   
   end
   
   
   methods
      
       function obj = updateCurve(obj, curveId, matrix)
            idIndex = numel(obj.curveGroupTitles) +  find(ismember(obj.curveTitles, 'Id'));
            [~, Locb] =  ismember(curveId, obj.curveGroups(:,idIndex));
            obj.curveGroups{Locb,end} = num2cell(matrix);
       end
       
   end
   
   
   %% Get Methods
   methods
       
       function [info] = getCurveGroups(obj)
           [id, ia, ~]  = unique(obj.curveGroups(:,1));
           info.id = id;
           info.name  = obj.curveGroups(ia,2);
           info.readOnly = obj.curveGroups(ia,3);
           info.n = numel(id);       
       end
       
       function [info] = getCurves(obj, groupId)
          selectedCurves = ismember(obj.curveGroups(:,1), groupId);
          info.id              = obj.curveGroups(selectedCurves, 4);
          info.name            = obj.curveGroups(selectedCurves, 5);
          info.readOnly        = obj.curveGroups(selectedCurves, 6);
          info.petrelTemplateX = obj.curveGroups(selectedCurves, 7);
          info.petrelTemplateY = obj.curveGroups(selectedCurves, 8);
          info.petroModUnitX   = obj.curveGroups(selectedCurves, 9);
          info.petroModUnitY   = obj.curveGroups(selectedCurves, 10);
          info.petroModId      = obj.curveGroups(selectedCurves, 11);
          info.curvePoints     = obj.curveGroups(selectedCurves, 12);
          info.n               = sum(selectedCurves);
       end
       
       function [docNode] = writeCurveNode(obj, docNode)
           [infoCurveGroup] = obj.getCurveGroups();
           for i=1:infoCurveGroup.n
              curveGroupElement = XMLTools.addElement(docNode, 'CurveGroup');
              XMLTools.addElement(curveGroupElement, 'Id', infoCurveGroup.id{i});
              XMLTools.addElement(curveGroupElement, 'Name', infoCurveGroup.name{i});
              XMLTools.addElement(curveGroupElement, 'ReadOnly', infoCurveGroup.readOnly{i});
              
              [infoCurves] = obj.getCurves(infoCurveGroup.id{i});
              if infoCurves.n > 1
              for j = 1:infoCurves.n
                 curveElement = XMLTools.addElement(curveGroupElement, 'Curve');
                 XMLTools.addElement(curveElement, 'Id', infoCurves.id{j});
                 XMLTools.addElement(curveElement, 'Name', infoCurves.name{j});
                 XMLTools.addElement(curveElement, 'ReadOnly', infoCurves.readOnly{j});
                 XMLTools.addElement(curveElement, 'PetrelTemplateX', infoCurves.petrelTemplateX{j});
                 XMLTools.addElement(curveElement, 'PetrelTemplateY', infoCurves.petrelTemplateY{j});
                 XMLTools.addElement(curveElement, 'PetroModUnitX', infoCurves.petroModUnitX{j});
                 XMLTools.addElement(curveElement, 'PetroModUnitY', infoCurves.petroModUnitY{j});
                 XMLTools.addElement(curveElement, 'PetroModId', infoCurves.petroModId{j});
                 nCurvePoints = size(infoCurves.curvePoints{j},1);
                 for k = 1:nCurvePoints
                   curvePointElement = XMLTools.addElement(curveElement, 'CurvePoint');
                   XMLTools.addElement(curvePointElement, 'X', infoCurves.curvePoints{j}(k,1));
                   XMLTools.addElement(curvePointElement, 'Y', infoCurves.curvePoints{j}(k,2));
                 end
              end
              end
           end

   end
          
           
       
   end

end