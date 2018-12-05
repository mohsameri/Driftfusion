classdef pc
    % Authors: Philip Calado, Piers Barnes, Ilario Gelmetti, Ben Hillman, 2018 Imperial College London
    % PC (Parameters Class) defines all the required properties for your
    % device. PC.BUILDDEV builds a structure PO.DEV (where PO is a Parameters Object)
    % that defines the properties of the device at every spatial mesh point, including
    % interfaces. Whenever PROPERTIES are overwritten, the device should 
    % be rebuilt using PC.BUILDDEV. The spatial mesh is a linear piece-wise mesh 
    % and is built by the MESHGEN_X function. Details of how to define the mesh 
    % are given below in the SPATIAL MESH SUBSECTION.
    
    properties (Constant)
        %% Physical constants
        kB = 8.617330350e-5;     % Boltzmann constant [eV K^-1]
        epp0 = 552434;           % Epsilon_0 [e^2 eV^-1 cm^-1] - Checked (02-11-15)
        q = 1;                   % Charge of the species in units of e.
        e = 1.61917e-19;         % Elementary charge in Coulombs.
        
    end
    
    properties
        
        % Temperature [K]
        T = 300;
        
        %% Spatial mesh
        % Device Dimensions [cm]
        % The spatial mesh is a linear piece-wise mesh and is built by the
        % MESHGEN_X function using 2 cell arrays DCELL and PCELL,
        % which define the thickness and number of points of each layer
        % respectively. Each layer is separated by a semi-colon but can be
        % sub-divided into different regions (with the same material
        % properties) to allow for variable point spacing. For example,the
        % following cell arrays:
        % dcell = {{180e-7, 20e-7}; {500e-7}}
        % pcell = {{180, 40}; {250}};
        % Would define a device with 2 layers of 200 nm and 500 nm
        % respectively. In the first layer the first 180 nm would have 180
        % points, whilst the final 20 nm of the layer would contain 40
        % points. The second layer would contain 250 points. This allows
        % for high density point spacing close to interfaces. Interfaces
        % are inserted automatically between each layer with a width
        % defined by the property DINT and number of points defined by
        % PINT.
        dcell = {{50e-7}; {30e-7, 450e-7, 30e-7}; {60e-7}};         % Layer and subsection thickness array
        pcell = {{50}; {30, 225, 30}; {60}};                          % Number of points in layers and subsections array  
        dint = 4e-7;        % Interfacial region thickness (x_mesh_type = 3)
        pint = 20;          % Interfacial points (x_mesh_type = 3)
        
        % Define spatial cordinate system- typeically this will be kept at
        % 0 for most applications
        % m=0 cartesian
        % m=1 cylindrical polar coordinates
        % m=2 spherical polar coordinates
        m = 0;
        
        % xmesh_type specification - see MESHGEN_X. Only type '3' is
        % currently in use
        xmesh_type = 3;
        
        %% Time mesh
        % The time mesh is dynamically generated by ODE15s- the mesh
        % defined by MESHGEN_T only defines the values of the points that
        % are read out and so does not influence convergence. Defining an
        % unecessarily high number of points however can be expensive owing
        % to interpolation of the solution.
        t0 = 1e-16;                 % Initial log mesh time value
        tmax = 1e-12;               % Max time value
        tpoints = 100;              % Number of time points
        tmesh_type = 2;             % Mesh type- for use with meshgen_t
        
        %% GENERAL CONTROL PARAMETERS
        OC = 0;                 % Closed circuit = 0, Open Circuit = 1
        Int = 0;                % Bias Light intensity (Suns Eq.)
        pulseon = 0;            % Switch pulse on TPC or TPV
        Vapp = 0;               % Applied bias
        BC = 3;                 % Boundary Conditions. Must be set to one for first solution
        figson = 1;             % Toggle figures on/off
        meshx_figon = 0;        % Toggles x-mesh figures on/off
        mesht_figon = 0;        % Toggles t-mesh figures on/off
        side = 1;               % illumination side 1 = EE, 2 = SE
        calcJ = 0;              % Calculates Currents- slows down solving calcJ = 1, calculates DD currents at every position
        mobset = 1;             % Switch on/off electron hole mobility- MUST BE SET TO ZERO FOR INITIAL SOLUTION
        mobseti = 1;
        SRHset = 1;
        JV = 0;                 % Toggle run JV scan on/off
        Ana = 1;                % Toggle on/off analysis
        stats = 'Boltz';        % 'Fermi' = Fermi-Dirac, % 'Boltz' = Boltzmann statistics
        
        %% OM = Optical Model
        % Uniform generation uses 
        % 0 = Uniform Generation
        % 1 = Beer Lambert
        OM = 0;
        
        %%%%%%%%%%% LAYER MATERIAL PROPERTIES %%%%%%%%%%%%%%%%%%%%
        % Numerical values should be given as a row vector with the number of 
        % entries equal to the number of layers specified in STACK 
        
        %% Layer description
        % Currently STACK is used for reading the optical properties
        % library. The names here do not influence the electrical properties of the
        % device. See INDEX OF REFRACTION LIBRARY for choices- names must be enetered 
        % exactly as given in the column headings with the '_n', '_k' omitted
        stack = {'PEDOT', 'MAPICl', 'PCBM'}
        
        %% Energy levels [eV] 
        EA = [-3.0, -3.8, -3.8];           % Electron affinity
        IP = [-5.1, -5.4, -6.2];           % Ionisation potential
        % PCBM: Sigma Aldrich https://www.sigmaaldrich.com/technical-documents/articles/materials-science/organic-electronics/pcbm-n-type-semiconductors.html 
        
        %% Equilibrium Fermi energies [eV]
        % These define the doping density in each layer- see NA and ND calculations in methods         
        E0 = [-5.0, -4.6, -3.9];   
        
        %% SRH trap energies [eV]
        % These must exist within the energy gap of the appropriate layers
        % and define the variables PT and NT in the expression:
        % U = (np-ni^2)/(taun(p+pt) +taup(n+nt))
        Et_bulk =[-4.05, -4.6, -5.0];
        
        %% Electrode Fermi energies [eV]
        % Fermi energies of the metal electrode. These define the built-in voltage, Vbi 
        % and the boundary carrier concentrations nleft, pleft, nright, and 
        % pright
        PhiA = -5.0;
        PhiC = -3.9;
        
        %% Effective Density Of States (eDOS) [cm-3]
        N0 = [1e19, 1e19, 1e19];
        % PEDOT eDOS: https://aip.scitation.org/doi/10.1063/1.4824104
        % MAPI eDOS: F. Brivio, K. T. Butler, A. Walsh and M. van Schilfgaarde, Phys. Rev. B, 2014, 89, 155204.
        % PCBM eDOS:
        
        %% Mobile ions
        % Mobile ion defect density [cm-3] 
        Nion = [0, 1e18, 0];                            % A. Walsh et al. Angewandte Chemie, 2015, 127, 1811.     
        % Approximate density of iodide sites [cm-3]
        % Limits the density of iodide vancancies
        DOSion = [1e-6, 1.21e22, 1e-6];                 % P. Calado thesis           
        
        %% Mobilities   [cm2V-1s-1]
        mue = [0.01, 20, 1e-3];         % electron mobility 
        muh = [0.01, 20, 1e-3];         % hole mobility
        
        muion = [0, 1e-10, 0];          % ion mobility
        % PTPD h+ mobility: https://pubs.rsc.org/en/content/articlehtml/2014/ra/c4ra05564k
        % PEDOT mue = 0.01 cm2V-1s-1 https://aip.scitation.org/doi/10.1063/1.4824104
        % TiO2 mue = 0.09 cm2V-1s-1 Bak2008
        % Spiro muh = 0.02 cm2V-1s-1 Hawash2018
        
        %% Relative dielectric constants
        epp = [4,23,4];    
                
        %% Uniform generation rate [cm-3s-1]
        G0 = [0, 2.6409e+21, 0];        % Approximate Uniform generation rate @ 1 Sun for 510 nm active layer thickness
        
        %% Recombination
        % Radiative recombination, U = k(np - ni^2)
        % [cm3 s-1] Radiative Recombination coefficient
        krad = [6.3e-11, 3.6e-12, 6.8e-11];
        
        %% Bulk SRH time constants for each layer [s]
        taun_bulk = [1e-6, 1e-6, 1e-6];           % [s] SRH time constant for electrons
        taup_bulk = [1e-6, 1e-6, 1e-6];           % [s] SRH time constant for holes   
        
        %% Interfacial SRH time constants [s]
        % Must be a row vector of length (number of layers)-1  
        taun_inter = [1e-13, 1e-6];
        taup_inter = [1e-13, 1e-6];

        %% Surface recombination and extraction coefficients [cm s-1]
        % Descriptions given in the comments considering that holes are
        % extracted at left boundary, electrons at right boundary
        sn_l = 1e8;     % electron surface recombination velocity left boundary
        sn_r = 1e8;     % electron extraction velocity right boundary
        sp_l = 1e8;     % hole extraction left boundary         
        sp_r = 1e8;     % hole surface recombination velocity right boundary
        
        %% Defect recombination rate coefficient
        % Currently not used
        k_defect_p = 0;
        k_defect_n = 0;
        
        %% Pulse settings
        laserlambda = 638;      % Pulse wavelength (Beer-Lambert and Transfer Matrix)
        pulselen = 1e-6;        % Transient pulse length
        pulsepow = 10;          % Pulse power [mW cm-2] OM2 (Beer-Lambert and Transfer Matrix only)
        pulsestart = 1e-7;      % Time recorded prior to pulse
        pulseint = 0.1;         % Pulse intensity (when using uniform generation)
        
        %% Current voltage scan parameters
        Vstart = 0;             % Initial scan point
        Vend = 1.2;             % Final scan point
        JVscan_rate = 1;        % JV scan rate (Vs-1)
        JVscan_pnts = 100;      % JV scan points
        
        %% Dynamically created variables
        genspace = [];
        x = [];
        xx = [];
        t = [];
        xpoints = [];
        Vapp_params = [];
        Vapp_func = @(str) [];
     
        % Define the default relative tolerance for the pdepe solver
        % 1e-3 is the default, can be decreased if more precision is needed
        % Solver options
        RelTol = 1e-3;
        AbsTol = 1e-6;
        
        dev;

    end
    
    
    %%  Properties whose values depend on other properties (see 'get' methods).
    properties (Dependent)
        d
        parr
        dcum
        dEAdx
        dIPdx
        dN0dx
        Dn
        Eg
        Eif
        NA
        ND
        Vbi
        n0
        nleft
        nright
        ni
        nt_bulk          % Density of CB electrons when Fermi level at trap state energy
        nt_inter
        p0
        pleft
        pright
        pt_bulk           % Density of VB holes when Fermi level at trap state energy
        pt_inter
        wn
        wp
        wscr            % Space charge region width
        x0              % Initial spatial mesh value
        
    end
    
    methods
        
        function par = pc
            % Parameters constructor function- runs numerous checks that
            % the input properties are consistent with the model
            
            % Warn if tmesh_type is not correct
            if ~ any([1 2 3 4] == par.tmesh_type)
                warning('PARAMS.tmesh_type should be an integer from 1 to 3 inclusive. MESHGEN_T cannot generate a mesh if this is not the case.')
            end
            
            % Warn if xmesh_type is not correct
            if ~ any(1:1:3 == par.xmesh_type)
                warning('PARAMS.xmesh_type should be an integer from 1 to 3 inclusive. MESHGEN_X cannot generate a mesh if this is not the case.')
            end
            
            % Warn if doping density exceeds eDOS
            for i = 1:length(par.ND)
                if par.ND(i) >= par.N0(i) || par.NA(i) >= par.N0(i)
                    msg = 'Doping density must be less than eDOS. For consistent values ensure electrode workfunctions are within the band gap and check expressions for doping density in Dependent variables.';
                    error(msg);
                end
            end
            
            % Warn if trap energies are outside of band gap energies
            for i = 1:length(par.Et_bulk)
                if par.Et_bulk(i) >= par.EA(i) || par.Et_bulk(i) <= par.IP(i)
                    msg = 'Trap energies must exist within layer band gap.';
                    error(msg);
                end
            end
            
            % Warn if DOSion is set to zero in any layers - leads to
            % infinite diffusion rate
            for i = 1:length(par.DOSion)
                if par.DOSion(i) <= 0
                    msg = 'ion DOS (DOSion) cannot have zero or negative entries- choose a low value rather than zero e.g. 1';
                    error(msg);
                end
            end
            
            % Warn if electrode workfunctions are outside of boundary layer
            % bandgap
            if par.PhiA < par.IP(1) || par.PhiA > par.EA(1)
                msg = 'Anode workfunction (PhiA) out of range: value must exist within left-hand layer band gap';
                error(msg)
            end
            
            if par.PhiC < par.IP(end) || par.PhiA > par.EA(end)
                msg = 'Anode workfunction (PhiA) out of range: value must exist within right-hand layer band gap';
                error(msg)
            end
            
            % Warn if property array do not have the correct number of
            % layers. The layer thickness array is used to define the
            % number of layers
            if length(par.parr) ~= length(par.d)
                msg = 'Points array (parr) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.EA) ~= length(par.d)
                msg = 'Electron Affinity array (EA) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.IP) ~= length(par.d)
                msg = 'Ionisation Potential array (IP) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.mue) ~= length(par.d)
                msg = 'Electron mobility array (mue) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.muh) ~= length(par.d)
                msg = 'Hole mobility array (mue) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.muion) ~= length(par.d)
                msg = 'Ion mobility array (muh) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.NA) ~= length(par.d)
                msg = 'Acceptor density array (NA) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.ND) ~= length(par.d)
                msg = 'Donor density array (ND) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.N0) ~= length(par.d)
                msg = 'Effective density of states array (N0) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.Nion) ~= length(par.d)
                msg = 'Background ion density (Nion) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.DOSion) ~= length(par.d)
                msg = 'Ion density of states array (DOSion) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.epp) ~= length(par.d)
                msg = 'Relative dielectric constant array (epp) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.krad) ~= length(par.d)
                msg = 'Radiative recombination coefficient array (krad) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.E0) ~= length(par.d)
                msg = 'Equilibrium Fermi level array (E0) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.G0) ~= length(par.d)
                msg = 'Uniform generation array (G0) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.taun_bulk) ~= length(par.d)
                msg = 'Bulk SRH electron time constants array (taun_bulk) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.taup_bulk) ~= length(par.d)
                msg = 'Bulk SRH hole time constants array (taup_bulk) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.Et_bulk) ~= length(par.d)
                msg = 'Bulk SRH trap energy array (Et_bulk) does not have the correct number of elements. Property arrays must have the same number of elements as the thickness array (d), except SRH properties for interfaces which should have length(d)-1 elements.';
                error(msg);
            elseif length(par.taun_inter) ~= length(par.d)-1
                msg = 'Interfacial electron SRH time constant array (taun_inter) does not have the correct number of elements. SRH properties for interfaces must have length(d)-1 elements.';
                error(msg);
            elseif length(par.taup_inter) ~= length(par.d)-1
                msg = 'Interfacial hole SRH time constant array (taup_inter) does not have the correct number of elements. SRH properties for interfaces must have length(d)-1 elements.';
                error(msg);
                
            end
            
            % Build the device- properties are defined at each point
            par.dev  = pc.builddev(par);
            % Build initial xmesh
            par.xx = pc.xmeshini(par);
        end
        
        function par = set.xmesh_type(par, value)
            %   SET.xmesh_type(PARAMS, VALUE) checks if VALUE is an integer
            %   from 1 to 3, and if so, changes PARAMS.xmesh_type to VALUE.
            %   Otherwise, a warning is shown. Runs automatically whenever
            %   xmesh_type is changed.
            if any(1:1:3 == value)
                par.xmesh_type = value;
            else
                error('PARAMS.xmesh_type should be an integer from 1 to 3 inclusive. MESHGEN_X cannot generate a mesh if this is not the case.')
            end
        end
        
        function par = set.tmesh_type(par, value)
            %   SET.tmesh_type(PARAMS, VALUE) checks if VALUE is an integer
            %   from 1 to 2, and if so, changes PARAMS.tmesh_type to VALUE.
            %   Otherwise, a warning is shown. Runs automatically whenever
            %   tmesh_type is changed.
            if any(1:1:3 == value)
                par.tmesh_type = value;
            else
                error('PARAMS.tmesh_type should be an integer from 1 to 3 inclusive. MESHGEN_T cannot generate a mesh if this is not the case.')
            end
        end
        
        function par = set.ND(par, value)
            for i = 1:length(par.ND)
                if value(i) >= par.N0(i)
                    error('Doping density must be less than eDOS. For consistent values ensure electrode workfunctions are within the band gap.')
                end
            end
        end
        
        function par = set.NA(par, value)
            for i = 1:length(par.ND)
                if value(i) >= par.N0(i)
                    error('Doping density must be less than eDOS. For consistent values ensure electrode workfunctions are within the band gap.')
                end
            end
        end
        
        %% Layer thicknesses [cm]
        function value = get.d(par)
            value = zeros(1, length(par.stack));
            for i=1:size(par.dcell, 1)
                tempcell = par.dcell{i, :};
                arr = cell2mat(tempcell);
                value(1, i) = sum(arr);                % cumulative thickness
            end
        end
        
        %% Layer points
        function value = get.parr(par)
            value = zeros(1, length(par.stack));
            for i=1:size(par.pcell, 1)
                tempcell = par.pcell{i, :};
                arr = cell2mat(tempcell);
                value(1, i) = sum(arr);                % cumulative thickness
            end
        end
        
        %% Cumulative layer thicknesses [cm]
        function value = get.dcum(par)
            value = cumsum(par.d);
        end
        
        %% Band gap energies    [eV]
        function value = get.Eg(par)
            value = par.EA - par.IP;
        end
        
        %% Built-in voltage Vbi based on difference in boundary workfunctions
        function value = get.Vbi(par)
            value = par.PhiC - par.PhiA;
        end
        
        %% Intrinsic Fermi Energies
        % Currently uses Boltzmann stats as approximation should always be 
        function value = get.Eif(par)
            value = [0.5*((par.EA(1)+par.IP(1))+par.kB*par.T*log(par.N0(1)/par.N0(1))),...
                0.5*((par.EA(2)+par.IP(2))+par.kB*par.T*log(par.N0(2)/par.N0(2))),...
                0.5*((par.EA(3)+par.IP(3))+par.kB*par.T*log(par.N0(3)/par.N0(3)))];  
        end
        
        %% Conduction band gradients at interfaces
        function value = get.dEAdx(par)
            value = [(par.EA(2)-par.EA(1))/(2*par.dint), (par.EA(3)-par.EA(2))/(2*par.dint)];
        end
        
        %% Valence band gradients at interfaces
        function value = get.dIPdx(par)
            value = [(par.IP(2)-par.IP(1))/(2*par.dint), (par.IP(3)-par.IP(2))/(2*par.dint)];
        end
        
        %% eDOS gradients at interfaces
        function value = get.dN0dx(par)    
            value = [(par.N0(2)-par.N0(1))/(2*par.dint), (par.N0(3)-par.N0(2))/(2*par.dint)];
        end
        
        %% Donor densities
        function value = get.ND(par) 
            value = [0, 0, F.nfun(par.N0(3), par.EA(3), par.E0(3), par.T, par.stats)];  
        end
        
        %% Donor densities
        function value = get.NA(par)
            value = [F.pfun(par.N0(1), par.IP(1), par.E0(1), par.T, par.stats), 0, 0];
        end
        
        %% Intrinsic carrier densities (Boltzmann)
        function value = get.ni(par)
            value = [par.N0(1)*(exp(-par.Eg(1)/(2*par.kB*par.T))),...
                par.N0(2)*(exp(-par.Eg(2)/(2*par.kB*par.T))),...
                par.N0(3)*(exp(-par.Eg(3)/(2*par.kB*par.T)))];   
        end
        
        %% Equilibrium electron densities
        function value = get.n0(par)
            value = [F.nfun(par.N0(1), par.EA(1), par.E0(1), par.T, par.stats),...
                F.nfun(par.N0(2), par.EA(2), par.E0(2), par.T, par.stats),...
                F.nfun(par.N0(3), par.EA(3), par.E0(3), par.T, par.stats)];
        end
        
        %% Equilibrium hole densitis
        function value = get.p0(par)
            value = [F.pfun(par.N0(1), par.IP(1), par.E0(1), par.T, par.stats),...
                F.pfun(par.N0(2), par.IP(2), par.E0(2), par.T, par.stats),...
                F.pfun(par.N0(3), par.IP(3), par.E0(3), par.T, par.stats)];
        end
        
        %% Boundary electron and hole densities
        % Uses metal Fermi energies to calculate boundary densities
        % Electrons left boundary
        function value = get.nleft(par)
            value = F.nfun(par.N0(1), par.EA(1), par.PhiA, par.T, par.stats);
        end
        
        % Electrons right boundary
        function value = get.nright(par)
            value = F.nfun(par.N0(end), par.EA(end), par.PhiC, par.T, par.stats);
        end
        
        % Holes left boundary
        function value = get.pleft(par)
            value = F.pfun(par.N0(1), par.IP(1), par.PhiA, par.T, par.stats);
        end
        
        % holes right boundary
        function value = get.pright(par)
            value = F.pfun(par.N0(end), par.IP(end), par.PhiC, par.T, par.stats);
        end
        
        %% Space charge layer widths
        % These were previously used to calculate initial conditions
        % In heterojunciton model these are currently not used
        function value = get.wp (par)
            value = ((-par.d(2)*par.NA(1)*par.q) + ((par.NA(1)^0.5)*(par.q^0.5)*(((par.d(2)^2)*par.NA(1)*par.q) + (4*par.epp(2)*par.Vbi))^0.5))/(2*par.NA(1)*par.q);
        end
        
        function value = get.wn (par)
            value = ((-par.d(2)*par.ND(3)*par.q) + ((par.ND(3)^0.5)*(par.q^0.5)*(((par.d(2)^2)*par.ND(3)*par.q) + (4*par.epp(2)*par.Vbi))^0.5))/(2*par.ND(3)*par.q);
        end
        
        % wscr - space charge region width
        function value = get.wscr(par)
            value = par.wp + par.d(2) + par.wn;         % cm
        end
        
        
    end
    
    methods (Static)
        
        function xx = xmeshini(par)
            
            xx = meshgen_x(par);
            
        end
        
        % EA array
        function dev = builddev(par)
            % BUILDDEV builds the properties for the device as
            % concatenated arrays such that each property can be called for
            % each point including grading at interfaces. For future
            % versions a choice of functions defining how the properties change
            % at the interfaces is intended. At present the
            % properties are graded linearly.
            xx = pc.xmeshini(par);
            
            dev.EA = zeros(1, length(xx));
            dev.IP = zeros(1, length(xx));
            dev.mue = zeros(1, length(xx));
            dev.muh = zeros(1, length(xx));
            dev.muion = zeros(1, length(xx));
            dev.NA = zeros(1, length(xx));
            dev.ND = zeros(1, length(xx));
            dev.N0 = zeros(1, length(xx));
            dev.Nion = zeros(1, length(xx));
            dev.ni = zeros(1, length(xx));
            dev.n0 = zeros(1, length(xx));
            dev.p0 = zeros(1, length(xx));
            dev.DOSion = zeros(1, length(xx));
            dev.epp = zeros(1, length(xx));
            dev.krad = zeros(1, length(xx));
            dev.gradEA = zeros(1, length(xx));
            dev.gradIP = zeros(1, length(xx));
            dev.gradN0 = zeros(1, length(xx));
            dev.E0 = zeros(1, length(xx));
            dev.G0 = zeros(1, length(xx));
            dev.taun = zeros(1, length(xx));
            dev.taup = zeros(1, length(xx));
            dev.Et = zeros(1, length(xx));
            dev.nt = zeros(1, length(xx));
            dev.pt = zeros(1, length(xx));
            
            % build cumulative d array with interfaces
            k = 1;
            darrint = zeros(1, 2*length(par.d)-1);
            for i=1:2*length(par.d)-1
                % i tracks the stack layers including interfaces
                % m tracks the stack layers
                if rem(i, 2) == 1
                    darrint(i) = par.d(k);
                    k = k+1;
                elseif rem(i, 2) == 0
                    darrint(i) = par.dint;
                end
                
            end
            darrcumint = cumsum(darrint);
            darrcumint = [0,darrcumint];
            
            if par.stats == 'Fermi'
                % Build diffusion coefficient structure
                for i =1:length(par.dcum)
                    startlim = par.IP(i);
                    endlim = par.EA(i)+0.6;
                    interval = (endlim-startlim)/400;
                    
                    Dfd_struct_n(i) = F.Dn_fd_fun(par.N0(i), par.EA(i), startlim:interval:endlim, par.mue(i), par.T);
                    
                    startlim = par.IP(i)-0.6;
                    endlim = par.EA(i);
                    interval = (endlim-startlim)/400;
                    
                    range = startlim:interval:endlim;
                    
                    Dfd_struct_p(i) = F.Dp_fd_fun(par.N0(i), par.IP(i), range, par.mue(i), par.T);
                end
            end
            
            % i is the stack layer index excluding interfaces
            % j is the xmesh index
            % k is the stack layer index including interfaces
            
            for k=1:length(darrint)
                i= ceil(k/2);
                for j = 1:length(xx)
                    if rem(k, 2) == 1
                        % 
                        if xx(j) >= darrcumint(k) %&& xx(j) <= darrcumint(k+1)
                            % Upper limits currently causing errors for final points-
                            % seems to be due to rounding. For now ignore
                            % upper limit- more expensive but prevents
                            % errors.
                            dev.EA(j) = par.EA(i);
                            dev.IP(j) = par.IP(i);
                            dev.mue(j) = par.mue(i);
                            dev.muh(j) = par.muh(i);
                            dev.muion(j) = par.muion(i);
                            dev.N0(j) = par.N0(i);
                            dev.NA(j) = par.NA(i);
                            dev.ND(j) = par.ND(i);
                            dev.epp(j) = par.epp(i);
                            dev.ni(j) = par.ni(i);
                            dev.Nion(j) = par.Nion(i);
                            dev.DOSion(j) = par.DOSion(i);
                            dev.krad(j) = par.krad(i);
                            dev.n0(j) = par.n0(i);
                            dev.p0(j) = par.p0(i);
                            dev.E0(j) = par.E0(i);
                            dev.G0(j) = par.G0(i);
                            dev.gradEA(j) = 0;
                            dev.gradIP(j) = 0;
                            dev.gradN0(j) = 0;
                            dev.taun(j) = par.taun_bulk(i);
                            dev.taup(j) = par.taup_bulk(i);
                            dev.Et(j) = par.Et_bulk(i);
                            
                            if par.stats =='Fermi'
                                % Electron diffusion coefficient lookup table
                                dev.Dnfun(j,:) = Dfd_struct_n(i).Dnfun;
                                dev.n_fd(j,:) = Dfd_struct_n(i).n_fd;
                                dev.Efn(j,:) = Dfd_struct_n(i).Efn;
                                % Hole diffusion coefficient lookup table
                                dev.Dpfun(j,:) = Dfd_struct_p(i).Dpfun;
                                dev.p_fd(j,:) = Dfd_struct_p(i).p_fd;
                                dev.Efp(j,:) = Dfd_struct_p(i).Efp;
                            end
                        end
                        
                    elseif rem(k, 2) == 0
                        % Interfaces
                        if xx(j) > darrcumint(k) && xx(j) < darrcumint(k+1)
                            
                            xprime = xx(j)-darrcumint(k);
                            % Electron affiniity
                            dEAdxprime = (par.EA(i+1)-par.EA(i))/(par.dint);
                            dev.EA(j) = par.EA(i) + xprime*dEAdxprime;
                            dev.gradEA(j) = dEAdxprime;
                            % Ionisation potential
                            dIPdxprime = (par.IP(i+1)-par.IP(i))/(par.dint);
                            dev.IP(j) = par.IP(i) + xprime*dIPdxprime;
                            dev.gradIP(j) = dIPdxprime;
                            % Electon mobility
                            dmuedx = (par.mue(i+1)-par.mue(i))/(par.dint);
                            dev.mue(j) = par.mue(i) + xprime*dmuedx;
                            % Hole mobility
                            dmuhdx = (par.muh(i+1)-par.muh(i))/(par.dint);
                            dev.muh(j) = par.muh(i) + xprime*dmuhdx;
                            % Ion mobility
                            dmuiondx = (par.muion(i+1)-par.muion(i))/(par.dint);
                            dev.muion(j) = par.muion(i) + xprime*dmuiondx;
                            % Effective density of states
                            dN0dx = (par.N0(i+1)-par.N0(i))/(par.dint);
                            dev.N0(j) = par.N0(i) + xprime*dN0dx;
                            dev.gradN0(j) = dN0dx;
                            % Acceptor density
                            dNAdx = (par.NA(i+1)-par.NA(i))/(par.dint);
                            dev.NA(j) = par.NA(i) + xprime*dNAdx;
                            % Donor density
                            dNDdx = (par.ND(i+1)-par.ND(i))/(par.dint);
                            dev.ND(j) = par.ND(i) + xprime*dNDdx;
                            % Dielectric constants
                            deppdx = (par.epp(i+1)-par.epp(i))/(par.dint);
                            dev.epp(j) = par.epp(i) + xprime*deppdx;
                            % Intrinsic carrier densities
                            dnidx = (par.ni(i+1)-par.ni(i))/(par.dint);
                            dev.ni(j) = par.ni(i) + xprime*dnidx;
                            % Equilibrium carrier densities
                            dn0dx = (par.n0(i+1)-par.n0(i))/(par.dint);
                            dev.n0(j) = par.n0(i) + xprime*dn0dx;
                            % Equilibrium carrier densities
                            dp0dx = (par.p0(i+1)-par.p0(i))/(par.dint);
                            dev.p0(j) = par.p0(i) + xprime*dp0dx;
                            % Equilibrium Fermi energy
                            dE0dx = (par.E0(i+1)-par.E0(i))/(par.dint);
                            dev.E0(j) = par.E0(i) + xprime*dE0dx;
                            % Uniform generation rate
                            dG0dx = (par.G0(i+1)-par.G0(i))/(par.dint);
                            dev.G0(j) = par.G0(i) + xprime*dG0dx;
                            % Static ion background density
                            dNiondx = (par.Nion(i+1)-par.Nion(i))/(par.dint);
                            dev.Nion(j) = par.Nion(i) + xprime*dNiondx;
                            % Ion density of states
                            dDOSiondx = (par.DOSion(i+1)-par.DOSion(i))/(par.dint);
                            dev.DOSion(j) = par.DOSion(i) + xprime*dDOSiondx;
                            % Radiative recombination coefficient
                            dkraddx = (par.krad(i+1)-par.krad(i))/(par.dint);
                            dev.krad(j) = par.krad(i) + xprime*dkraddx;
                            % SRH trap elvel
                            dEtdx = (par.Et_bulk(i+1)-par.Et_bulk(i))/(par.dint);
                            dev.Et(j) = par.Et_bulk(i) + xprime*dEtdx;
                            % SRH time constants
                            dev.taun(j) = par.taun_inter(i);
                            dev.taup(j) = par.taup_inter(i);
                            
                            if par.stats == 'Fermi'
                                % Build diffusion coefficient structure
                                startlim = dev.IP(j);
                                endlim = dev.EA(j)+1.0;
                                interval = (endlim-startlim)/400;
                                
                                Dfd_struct_n_temp = F.Dn_fd_fun(dev.N0(j), dev.EA(j), startlim:interval:endlim, dev.mue(j), par.T);
                                
                                dev.Dnfun(j,:) = Dfd_struct_n_temp.Dnfun;
                                dev.n_fd(j,:) = Dfd_struct_n_temp.n_fd;
                                dev.Efn(j,:) = Dfd_struct_n_temp.Efn;
                                
                                startlim = dev.IP(j)-1.0;
                                endlim = dev.EA(j);
                                interval = (endlim-startlim)/400;
                                
                                Dfd_struct_p_temp = F.Dp_fd_fun(dev.N0(j), dev.IP(j), startlim:interval:endlim, dev.mue(j), par.T);
                                
                                dev.Dpfun(j,:) = Dfd_struct_p_temp.Dpfun;
                                dev.p_fd(j,:) = Dfd_struct_p_temp.p_fd;
                                dev.Efp(j,:) = Dfd_struct_p_temp.Efp;
                            end
                        end
                    end
                end
                
            end
            
%             Alternative gradient calculation appears less stable
%             dev.gradN0 = gradient(dev.N0, xx);
%             dev.gradEA = gradient(dev.EA, xx);
%             dev.gradIP = gradient(dev.IP, xx);
             dev.nt = F.nfun(dev.N0, dev.EA, dev.Et, par.T, par.stats);
             dev.pt = F.pfun(dev.N0, dev.IP, dev.Et, par.T, par.stats);
        end
 
    end
end
