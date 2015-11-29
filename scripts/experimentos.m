clear;clc;
output = '/Users/larrypavanery/Dropbox/TCC/1/Experimentos/output';
root = '/Users/larrypavanery/Dropbox/TCC/1/Experimentos/db/TI46/TI20/TRAIN/';

classes = [3, 5, 7, 10];
uterances = [5, 10];
loc_masc = [4, 8];
loc_fem = [4, 8];

timeStamp = strrep(mat2str(fix(clock)), ' ', '');

disp('Running train...');

for i = 1:length(classes)
    num_classes = classes(i);
    
    for j = 1:length(uterances)
        num_uterances = uterances(j);
        
        for k = 1:length(loc_masc)
            num_loc_masc = loc_masc(k);
            
            for l = 1:length(loc_fem)
                num_loc_fem = loc_fem(l);
                
                tamanho = java.util.ArrayList;
                insig = [];
                
                for m = 1:num_classes
                    %male
                    for n = 1:num_loc_masc
                        diretorio = [root 'M' int2str(n)];
                        arquivos = dir(diretorio);
                        for r = 4 + 10 * (m - 1): 10 * (m - 1) + num_uterances + 4 -1
                            path = [diretorio '/' arquivos(r).name];
                            [audio fs] = audioread(path);
                            insig = [insig audio(:,1)'];
                        end
                    end
                    %female
                    for n = 1:num_loc_fem
                        diretorio = [root 'F' int2str(n)];
                        arquivos = dir(diretorio);
                        for r = 4 + 10 * (m - 1): 10 * (m - 1) + num_uterances + 4 -1
                            path = [diretorio '/' arquivos(r).name];
                            [audio fs] = audioread(path);
                            insig = [insig audio(:,1)'];
                        end
                    end

                    tamanho.add(length(insig));
                end
                %Define a transposta
                insig = insig';

                %processamento do ouvido
                outsig0 = drnl(insig(:,1), 2*fs, 'bwmul', .5);
                outsig0 = ihcenvelope(outsig0, 2*fs, 'ihc_dau');
                
                X = outsig0;

                iter = 2 ^ (num_classes - 1);
                idx = 0;
                regressoes = [];
                Y = [];
                
                %Calc Regress para Masc. e Femin.
                while iter >= 1
                    bin = [dec2bin(iter, num_classes) ''];
                    for p = 1:(num_classes)
                        idx = idx + 1;

                        if p == 1
                            a = p;
                        else
                            a = (p - 2);
                        end

                        b = (p - 1);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %   Para cada conjunto de dados pertencente a uma uterancia,
                        % multiplicar ele por 1 e os demais conjuntos por 0.
                        %   Isso fara com que cada conjunto de dados de uma uterancia seja
                        % reconhecido, gerando o que eh chamado de "class" de cada uterancia.
                        %   Exemplo: Se esta sendo realizado o treinamento para as uterancias
                        % "one" e "two", primeiro passo, multiplicar os dados de "one" por 1
                        % e de "two" por 0, logo depois multiplicar "two" por 1 e "one" por 0.
                        %   Dessa forma, existira uma matriz com os dados representativos de
                        % cada uterancia, para a previsao de valores futuros, novas uterancias. 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if p == 1
                           Y(a:tamanho.get(b)) = str2num(bin(idx));
                        else
                           Y(tamanho.get(a) + 1:tamanho.get(b)) = str2num(bin(idx));
                        end

                        if idx == num_classes
                            idx = 0;
                        end
                    end
                    
					%gera matriz de 61xP, em que P eh a quantidade de classes
                    regressoes = [regressoes regress(Y', X)];
                    iter = iter / 2;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Salvar experimento completo em arquivo
                %se experimento possui as classes zero, one e two, então
                %será salvo um arquivo csv, em que cada coluna representara
                %o treinamento de uma classe, seguindo a ordem de
                %treinamento, ou seja, primeira coluna estara o treinamento
                %de zero, segunda de one e terceira de two e assim
                %sucessivamente para um experimento com mais classes.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                dlmwrite([output '/' timeStamp '-experimento[class-' int2str(num_classes) '-uterances-' int2str(num_uterances) '-num_loc_masc-' int2str(num_loc_masc) '-num_loc_fem-' int2str(num_loc_fem) '].csv'], regressoes, 'delimiter', ';', 'precision', 4)

            end
        end
    end
end

disp('Done.');


