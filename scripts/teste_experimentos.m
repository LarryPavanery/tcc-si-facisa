clear;clc;
output = '/Users/larrypavanery/Dropbox/TCC/1/Experimentos/output';
pathTest = '/Users/larrypavanery/Dropbox/TCC/1/Experimentos/db/TI46/TI20/TEST/';

class = java.util.ArrayList;
class.add('zero');
class.add('one');
class.add('two');
class.add('three');
class.add('four');
class.add('five');
class.add('six');
class.add('seven');
class.add('eight');
class.add('nine');

treinamentos = [output '/classes/'];
experimentos = dir(treinamentos);
quantidadePessoa = 1;
fazTeste = 1;
genero = 'M';

disp('Running test...');
while (fazTeste <= 2)
    partPathGenero = strcat(genero, int2str(quantidadePessoa));
    fullPathGenero = strcat(pathTest, partPathGenero);
    disp(fullPathGenero);
    
    for exp = 4:length(experimentos)
       head = [];
       assertiveness = [];
       treinamento = experimentos(exp).name;
       filename = [output '/classes/' treinamento];
       regressoes = dlmread(filename, ';');

       %para cada base de treinamento, realizar os testes de suas classes.
        len_regres = min(size(regressoes));
        disp(strcat('len regressoes: ', int2str(len_regres)));

        %cria matriz de confusao
        matrizconfusao = javaArray('java.lang.Integer', len_regres, len_regres);

        %inicializa matriz de confusao
        for inita = 1:len_regres
            for initb = 1:len_regres
                matrizconfusao(inita, initb) = java.lang.Integer(0);
            end
        end

        for i = 0:(len_regres - 1)
            %escreve head
            head = [head i];

            %testa cada uma das classes que foram treinadas
            clas = i;

            diretorio = [fullPathGenero '/' class.get(clas)];
            arquivos = dir(diretorio);

            %para cada uterancia pertencente ao locutor, testar com as classes treinadas
            totalArquivos = length(arquivos);
            disp(strcat('Audio read of class: ', class.get(clas)));
            for j = 4:totalArquivos
                insig = [];
                path = [diretorio '/' arquivos(j).name];
                [audio fs] = audioread(path);
                insig = [insig audio(:,1)'];
                insig = insig';

                %faz processamento do modelo do ouvido
                outsig = drnl(insig(:,1), 2*fs, 'bwmul', .5);
                outsig = ihcenvelope(outsig, 2*fs, 'ihc_dau');

                medias = [];

                for ii = 1:len_regres
                    result = outsig * regressoes(:,ii);
                    medias = [medias mean(result)];
                end

                %soma erros e acertos
                [maxmedia, index] = max(medias);
                incrementa = java.lang.Integer(matrizconfusao(index, clas + 1).intValue + 1);
                matrizconfusao(index, clas + 1) = incrementa;
            end
            %calcula acertividade
            acertos = matrizconfusao(clas + 1, clas + 1).intValue;
            totalArquivos = totalArquivos - 3;

            acertividade = (acertos/totalArquivos) * 100;
            assertiveness = [assertiveness acertividade];
        end

        timeStamp = strrep(mat2str(fix(clock)), ' ', '');
        filenametest = [output '/matrizesConfusao/' timeStamp '-test-with-training[' treinamento ']-assertiveness[' mat2str(assertiveness) '%]-user[' partPathGenero '].csv'];

        matrizconfusaOutput = cell2mat(cell(matrizconfusao));
        dlmwrite(filenametest, head, '-append', 'delimiter', ';', 'precision', 2);
        dlmwrite(filenametest, matrizconfusaOutput, '-append', 'delimiter', ';', 'precision', 2);
    end
    
    if (quantidadePessoa == 4) 
       quantidadePessoa = 0; 
       fazTeste = fazTeste + 1;
       genero = 'F';
    end
    
    quantidadePessoa = quantidadePessoa + 1;
end
disp('Done.');




