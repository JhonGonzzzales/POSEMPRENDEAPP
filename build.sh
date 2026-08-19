#!/bin/bash
if [ -d "flutter" ]; then
    echo "Flutter SDK ya existe"
else
    echo "Clonando Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
flutter build web --release