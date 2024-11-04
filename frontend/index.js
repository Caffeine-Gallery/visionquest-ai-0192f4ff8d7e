import { backend } from 'declarations/backend';

const imageUpload = document.getElementById('imageUpload');
const processButton = document.getElementById('processButton');
const originalImage = document.getElementById('originalImage');
const processedImage = document.getElementById('processedImage');
const loadingSpinner = document.getElementById('loadingSpinner');
const errorMessage = document.getElementById('errorMessage');

processButton.addEventListener('click', processImage);

async function processImage() {
    const file = imageUpload.files[0];
    if (!file) {
        showError('Please select an image to process.');
        return;
    }

    showLoading(true);
    clearError();

    try {
        const imageData = await readFileAsArrayBuffer(file);
        const result = await backend.processImage(Array.from(new Uint8Array(imageData)));

        if (result.error) {
            showError(result.error);
        } else {
            displayResults(file, result.processedImageData);
        }
    } catch (error) {
        showError('An error occurred while processing the image.');
        console.error(error);
    } finally {
        showLoading(false);
    }
}

function readFileAsArrayBuffer(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsArrayBuffer(file);
    });
}

function displayResults(originalFile, processedImageData) {
    const originalUrl = URL.createObjectURL(originalFile);
    originalImage.src = originalUrl;
    originalImage.style.display = 'block';

    const processedBlob = new Blob([new Uint8Array(processedImageData)], { type: 'image/png' });
    const processedUrl = URL.createObjectURL(processedBlob);
    processedImage.src = processedUrl;
    processedImage.style.display = 'block';
}

function showLoading(isLoading) {
    loadingSpinner.style.display = isLoading ? 'block' : 'none';
    processButton.disabled = isLoading;
}

function showError(message) {
    errorMessage.textContent = message;
    errorMessage.style.display = 'block';
}

function clearError() {
    errorMessage.textContent = '';
    errorMessage.style.display = 'none';
}
