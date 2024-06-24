Image Compression and Reconstruction Using Huffman Encoding
Description
This project demonstrates image compression and reconstruction using Huffman encoding and BPSK modulation in MATLAB. The process involves reading a grayscale image, compressing it using Huffman coding, transmitting it over a noisy channel using BPSK modulation, and then reconstructing the image at the receiver end. The bit error rate (BER) is also calculated to evaluate the performance.

Installation Instructions
Clone the Repository:
bash
Copy code
git clone https://github.com/your-username/your-repository.git
Navigate to the Project Directory:
bash
Copy code
cd your-repository
Usage Instructions
Place the Input Image:

Ensure the input image cropped_image.png is in the project directory.
Run the MATLAB Script:

Open MATLAB.
Run the provided MATLAB script image_compression.m or paste the code into your MATLAB environment.
Detailed Description of the Code
Steps Involved:
Read and Convert Image:

matlab
Copy code
image_rgb = imread('cropped_image.png');
image_gray = rgb2gray(image_rgb);
imshow(image_gray);
Calculate Histogram and Probability:

matlab
Copy code
[rows, columns] = size(image_gray);
occur = zeros(1, 256);
for i = 1:rows
    for j = 1:columns
        occur(image_gray(i, j) + 1) = occur(image_gray(i, j) + 1) + 1;
    end
end
prob = occur ./ (rows * columns);
Huffman Encoding:

matlab
Copy code
codebook = huffman_encode(prob);
Generate Source Bitstream:

matlab
Copy code
src_bitstream = '';
for i = 1:rows
    for j = 1:columns
        symbol = image_gray(i, j);
        codeword = char(codebook(symbol + 1));
        src_bitstream = strcat(src_bitstream, codeword);
    end
end
BPSK Modulation:

matlab
Copy code
len = length(src_bitstream);
bpsk_seq = zeros(1, len);
for i = 1:len
    c = src_bitstream(i);
    bpsk_seq(i) = c == '1' ? 1 : -1;
end
Add AWGN:

matlab
Copy code
snr = 11;
rx_seq = awgn(bpsk_seq, snr);
Demodulate and Decode:

matlab
Copy code
rx_bitstream = '';
for i = 1:len
    rx_bitstream = strcat(rx_bitstream, rx_seq(i) > 0 ? '1' : '0');
end
Reconstruct Image:

matlab
Copy code
rx_image = zeros(rows, columns);
r = 1;
c = 1;
detected_code = '';
for i = 1:len
    detected_code = strcat(detected_code, rx_bitstream(i));
    for j = 1:256
        if strcmp(detected_code, char(codebook(j)))
            rx_image(r, c) = j - 1;
            detected_code = '';
            if c == columns
                r = r + 1;
                c = 1;
            else
                c = c + 1;
            end
            break;
        end
    end
end
rx_image = uint8(rx_image);
imshow(rx_image);
Calculate Bit Error Rate (BER):

matlab
Copy code
err_bits = sum(src_bitstream ~= rx_bitstream);
ber = err_bits / len;
disp(['Bit Error Rate (BER) = ', num2str(ber)]);
Huffman Encoding Function:
The function huffman_encode(prob) constructs a Huffman codebook based on symbol probabilities.

Results
After running the script, the reconstructed image will be displayed, and the bit error rate (BER) will be printed in the MATLAB command window.

Dependencies and Requirements
MATLAB (R2019b or later recommended)
Image Processing Toolbox
Contact Information
For any questions or issues, please contact:

Name: Your Name
Email: your.email@example.com
License
This project is licensed under the MIT License - see the LICENSE file for details.
