%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Copyright 2019 Mohammad Al-Sa'd
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% Authors: Mohammad F. Al-Sa'd     (mohammad.al-sad@tuni.fi)
%          Prof. Boualem Boashash  (b.boashash@uq.edu.au)
%
% The following reference should be cited whenever this script is used:
%   M. Al-Sa'd, B. Boashash, "Design and implementation of a multi-sensor
%   newborn EEG seizure and background model with inter-channel field
%   characterization", Digital Signal Processing, 2019.
%
% Last Modification: 25-Jan-2019
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%% Initialisation
clear; close all; clc;
addpath(genpath('Toolbox'));
addpath(genpath('Data\Simulated EEG'));

%% Parameters
M    = 7;     % Total number of patients
Nfft = 256;   % Total number of frequency bins

%% Main
for m = 1:M
    disp(['Patient No. ' num2str(m)])
    % Loading Real EEG
    load(['Patient_' num2str(m)],'X_sim_seg_noisy','mask_seg','Channel_label');
    Ne   = size(X_sim_seg_noisy,1);
    Nb   = size(X_sim_seg_noisy,1)-sum(mask_seg);
    Ns   = sum(mask_seg);
    ch_n = size(X_sim_seg_noisy,2);
    N    = size(X_sim_seg_noisy,3);
    EEG_S = zeros(Ns,ch_n,N);
    EEG_B = zeros(Nb,ch_n,N);
    cnt1 = 0; cnt2 = 0;
    for ne = 1:Ne
        if(mask_seg(ne))
            cnt1 = cnt1 + 1;
            EEG_S(cnt1,:,:) = X_sim_seg_noisy(ne,:,:);
        else
            cnt2 = cnt2 + 1;
            EEG_B(cnt2,:,:) = X_sim_seg_noisy(ne,:,:);
        end
    end
    CB_t  = cell(1,Nb);
    CS_t  = cell(1,Ns);
    tmp = [];
    % Time-Domain Correlation Analysis
    disp('Time-domain correlation analysis ...');
    for nb = 1:Nb
        tmp(:,:) = EEG_B(nb,:,:);
        CB_t{1,nb} = abs(corr(tmp',tmp'));
    end
    tmp = [];
    for ns = 1:Ns
        tmp(:,:) = EEG_S(ns,:,:);
        CS_t{1,ns} = abs(corr(tmp',tmp'));
    end
    % Time-Frequency Domain Correlation Analysis
    disp('Time-frequency correlation analysis ...');
    CB_tf = cell(1,Nb);
    CS_tf = cell(1,Ns);
    for nb = 1:Nb
        temp(:,:) = EEG_B(nb,:,:);
        tmp = zeros(ch_n,N*Nfft);
        for c = 1:ch_n
            dump = abs(quadtfd(temp(c,:), N/4-1, 1, 'emb',0.075,0.5,Nfft));
            tmp(c,:) = reshape(dump,1,N*Nfft);
        end
        CB_tf{1,nb} = abs(corr(tmp',tmp'));
    end
    for ns = 1:Ns
        temp(:,:) = EEG_S(ns,:,:);
        tmp = zeros(ch_n,N*Nfft);
        for c = 1:ch_n
            dump = abs(quadtfd(temp(c,:), N/4-1, 1, 'emb',0.025,0.5,Nfft));
            tmp(c,:) = reshape(dump,1,N*Nfft);
        end
        CS_tf{1,ns} = abs(corr(tmp',tmp'));
    end
    % Saving
    disp('Saving ...')
    save(['Data\Correlation\simulated_EEG_' num2str(m) '_corr.mat'],'CB_t','CS_t','CB_tf','CS_tf','Channel_label');
end
