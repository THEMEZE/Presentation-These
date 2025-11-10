import fitz  # PyMuPDF
import imageio.v3 as iio
from PIL import Image
import numpy as np
from tqdm import tqdm

pdf_path = "main.pdf"
gif_path = "main.gif"

# Paramètres
zoom = 2.0               # Zoom pour la qualité
fps = 10                 # Images par seconde
fade_frames = 10         # Nombre d'images de fondu entre deux pages
frame_duration = 1 / fps # Durée d'une image
images = []

# Extraction des pages du PDF
doc = fitz.open(pdf_path)
pages = []
for page in doc:
    pix = page.get_pixmap(matrix=fitz.Matrix(zoom, zoom))
    img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
    pages.append(img)

# Création du GIF avec transitions fondues
for i in tqdm(range(len(pages))):
    images.append(pages[i])
    if i < len(pages) - 1:
        img1 = np.array(pages[i]).astype(float)
        img2 = np.array(pages[i + 1]).astype(float)
        # Génère les frames de transition
        for alpha in np.linspace(0, 1, fade_frames):
            blend = (1 - alpha) * img1 + alpha * img2
            images.append(Image.fromarray(np.uint8(blend)))

# Sauvegarde du GIF
iio.imwrite(gif_path, images, duration=frame_duration, loop=0)
print(f"✅ GIF créé avec effet de fondu : {gif_path}")