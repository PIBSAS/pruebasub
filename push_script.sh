#!/bin/bash

# Configura las variables
SOURCE_DIR="../apush"    # Carpeta de origen
DEST_DIR="."           # Carpeta de destino (root del repo)
MAX_SIZE=500000000     # Tamaño máximo en bytes (500 MB)

# Asegúrate de que la carpeta de origen existe
if [ ! -d "$SOURCE_DIR" ]; then
  echo "La carpeta de origen '$SOURCE_DIR' no existe."
  exit 1
fi

# Función para mover archivos
move_files() {
  local total_size=0
  local file_count=0

  # Lee los archivos en la carpeta de origen
  for file in "$SOURCE_DIR"/*; do
    # Verifica si es un archivo
    if [ -f "$file" ]; then
      file_size=$(stat -c%s "$file")
      # Verifica si agregar este archivo excede el tamaño máximo
      if (( total_size + file_size <= MAX_SIZE )); then
        # Mover el archivo al directorio de destino
        mv "$file" "$DEST_DIR/"
        total_size=$(( total_size + file_size ))
        file_count=$(( file_count + 1 ))
      fi
    fi
  done

  # Si se movieron archivos, realiza el commit y push
  if [ $file_count -gt 0 ]; then
    echo "Movidos $file_count archivos, total: $total_size bytes."
    git add .
    git commit -m "Agregando archivos del directorio '$SOURCE_DIR'"
    git push -u origin main
  fi
}

# Repite hasta que la carpeta de origen esté vacía
while [ "$(ls -A "$SOURCE_DIR")" ]; do
  move_files
done

echo "Todos los archivos han sido movidos."
