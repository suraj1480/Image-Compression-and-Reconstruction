image_rgb = imread('cropped_image.png');
image_gray = rgb2gray(image_rgb);
imshow(image_gray)
[rows,columns]=size(image_gray);
occur = zeros(1,256);
for i=1:rows
    for j=1:columns
        occur(image_gray(i,j)+1)=occur(image_gray(i,j)+1)+1;
    end
end

prob = occur ./ (rows*columns); 


codebook = huffman_encode(prob);

max_code_length=0;
for i = 1:256
    x = length(char(codebook(i)));
    if x>max_code_length
        max_code_length=x;
    end
end

src_bitstream='';
for i = 1:rows
    for j=1:columns
        symbol = image_gray(i,j);
        codeword = char(codebook(symbol+1));    
        src_bitstream = strcat(src_bitstream, codeword);
    end
end

len = length(src_bitstream);
bpsk_seq = zeros(1, len);

for i = 1:len
    c = src_bitstream(i);
    if c == '1'
        bpsk_seq(i)=1;
    else
        bpsk_seq(i)=-1;
    end
end

snr=11;
rx_seq = awgn(bpsk_seq,snr);


rx_bitstream = '';

for i = 1:len
    a = rx_seq(i);
    if a>0
        rx_bitstream = strcat(rx_bitstream,'1');
    else
        rx_bitstream = strcat(rx_bitstream,'0');
    end
end

rx_image = zeros(rows,columns);
r=1;
c=1;
detected_code = '';
for i = 1:len
    detected_code = strcat(detected_code,rx_bitstream(i));
    flag=0;
    for j = 1:256
        if length(detected_code) == length(char(codebook(j)))
            if detected_code == char(codebook(j))
                rx_image(r,c) = j-1;
                detected_code='';
                flag=1;
                if c == columns
                    r=r+1;
                    c=1;
                else
                    c=c+1;
                end
            break;
            end
        end
    end

    if length(detected_code) == max_code_length
        if flag==0
            rx_image(r,c) = 255;
            detected_code='';
            if c == columns
                r=r+1;
                c=1;
            else
                c=c+1;
            end
        end
    end
end

rx_image = uint8(rx_image);
imshow(rx_image)

err_bits=0;
for i=1:len
    if src_bitstream(i)~=rx_bitstream(i)
        err_bits=err_bits+1;
    end
end
ber = err_bits / len;
disp(['Bit Error Rate (BER) = ', num2str(ber)])

function codebook = huffman_encode(prob)

nodes = cell(256,1);

for i = 1:256
    nodes{i}=struct('symbol',i-1,'probability',prob(i),'codeword','');
end

while length(nodes)>1
    [~,sorted_index]=sort(cellfun(@(x)x.probability,nodes));
    nodes=nodes(sorted_index);

    node_1 = nodes{1};
    node_2 = nodes{2};

    for i = 1:length(node_1)
        nodes{i}.codeword=['0' nodes{i}.codeword];
    end 

    for i = 1:length(node_2)
        nodes{i}.codeword=['1' nodes{i}.codeword];
    end

    newNode = struct('symbol', [], 'probability', node_1.probability + node_2.probability,'codeword', '');
    newNode.children = {node_1, node_2};
    nodes = nodes(3:end);
    nodes{end+1} = newNode;
end

codebook = cell(256, 1);
traverse(nodes{1}, '');

function traverse(node, codeword)
        if isempty(node.symbol)
            traverse(node.children{1}, [codeword '0']);
            traverse(node.children{2}, [codeword '1']);
        else
            codebook{node.symbol + 1} = codeword;
        end
end
end

