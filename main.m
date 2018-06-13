clear all

% Define parameters
PMDirectory = 'C:\Program Files\Schlumberger\PetroMod 2017.1\WIN64\bin';
PMProjectDirectory = 'C:\Users\malibrah\Desktop\T17';

nDim = 1;   % is your model 1D, 2D, or 3D
templateModel = 'M1DEmpty';
newModel ='UpdatedModel';

% Open the project
PM = PetroMod(PMDirectory, PMProjectDirectory);

% Check the current parameter of the lithology (curves are showed as id)
lithoInfo = PM.Litho.getLithologyInfo('Shale (typical)')

% Get some parameters (works on both scaler and curve)
athysFactor = PM.Litho.getValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)')
heatCapacityCurve = PM.Litho.getValue('Sandstone (clay rich)', 'Heat Capacity Curve')

% Change some parameters (one scaler, and one curve)
PM.Litho.changeValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', .4);
PM.Litho.changeValue('Sandstone (clay rich)', 'Heat Capacity Curve', [0 10; 10 100]);

% Add and delete lithology
PM.Litho.deleteLithology('Mos Lithology');
PM.Litho.dublicateLithology('Sandstone (clay rich)', 'Mos Lithology', 'MainGroup', 'SubGroup')
PM.Litho.changeLithologyGroup('Mos Lithology', 'MainGroup', 'Test')
PM.Litho.deleteLithology('Mos Lithology');

% Create a lithology mix
PM.Litho.deleteLithology('MosMix');
mixer = LithoMixer('V');
sourceLithologies = {'Sandstone (typical)','Shale (typical)'};
%sourceLithologies = {'SandstoneMos','ShaleMos'};
fractions         = [.5, .5];
PM.Litho.mixLitholgies(sourceLithologies, fractions, 'MosMix' , mixer);

% Update lithology file (needed if you change the lithology file)
PM.updateProject();

% Create a new model and delete model
PM.dublicateModel(templateModel, newModel, nDim);

% Update model
% - See below

% Simulate model
[output] = PM.simModel(newModel, nDim, true);

% Run a custom script on the output
[cmdout, status] = PM.runScript(newModel, nDim, 'demo_opensim_output_3rd_party_format', '4', true);
[cmdout, status] = PM.runScript(newModel, nDim, 'demo_ExtractOutput', '1');

% Restore lithology file (does not restore models)
PM.restoreProject();
PM.deleteModel(newModel, nDim);

%% Model operations

% Load Model
model = Model1D(newModel, PMProjectDirectory);

% Get the names of data tables
model.getTableNames()

% Update the some table data (matrix table) and check if it is updated
model.printTable('Heat Flow');
data = model.getData('Heat Flow');
data(:,2) = data(:,2)*2;
model.updateData('Heat Flow', data);
model.printTable('Heat Flow');

% Some tables have some titles, you can just give the update data the key
% (title) of the updated value to update it. Or you can get all the data
% and update it manually and then pass it without the key as above
model.printTable('Simulation');
model.updateData('Simulation', [20 10], 'Oeve');
model.printTable('Simulation');

% Update the model and to the files
model.updateModel();




