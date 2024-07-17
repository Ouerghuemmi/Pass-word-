# Pass-word-
Vérifier et Accès à toute pass word  
import hashlib
import getpass
import tkinter as tk
from tkinter import messagebox
from cryptography.fernet import Fernet
import random
import itertools

# Constantes
N = 8  # nombre de chiffres dans le mot de passe
K = 10  # nombre de chiffres disponibles (0 à 9)

def generate_password(n: int, k: int) -> str:
    """
    Génère un mot de passe aléatoire de n chiffres
    en utilisant les k chiffres disponibles (0 à 9)
    """
    password = ""
    for i in range(n):
        password += str(random.randint(0, k-1))
    return password

def hash_password(password: str) -> str:
    """
    Hash le mot de passe en utilisant SHA-256
    """
    return hashlib.sha256(password.encode()).hexdigest()

def check_password(stored: str, input_password: str) -> bool:
    """
    Vérifie si le mot de passe saisi correspond
    au mot de passe stocké
    """
    return stored_password == hash_password(input_password)

def test_all_passwords(n: int, k: int, stored_password: str) -> str:
    """
    Teste toutes les combinaisons possibles de mots de passe
    pour trouver le mot de passe correct
    """
    for password in itertools.product(range(k), repeat=n):
        password_str = ''.join(str(x) for x in password)
        if hash_password(password_str) == stored_password:
            return password_str
    return None

def main():
    """
    Fonction principale du programme
    """
    password = generate_password(N, K)
    print(f"Mot de passe généré : {password}")

    stored_password = hash_password(password)

    # Teste toutes les combinaisons possibles de mots de passe
    correct_password = test_all_passwords(N, K, stored_password)

    if correct_password:
        print(f"Mot de passe correct trouvé : {correct_password}")
    else:
        print("Mot de passe correct non trouvé")

if __name__ == "__main__":
    main()

def generate_key() -> bytes:
    """
    Génère une clé de cryptage
    """
    return Fernet.generate_key()

def encrypt_password(key: bytes, password: str) -> str:
    """
    Crypte le mot de passe en utilisant la clé
    """
    f = Fernet(key)
    return f.encrypt(password.encode()).decode()

def decrypt_password(key: bytes, encrypted_password: str) -> str:
    """
    Décrypte le mot de passe en utilisant la clé
    """
    f = Fernet(key)
    return f.decrypt(encrypted_password.encode()).decode()

passwords = {}

def add_password():
    """
    Ajoute un mot de passe à la base de données
    """
    service = service_entry.get()
    guest_network = guest_network_entry.get()
    password = password_entry.get()
    if service and guest_network and password:
        encrypted_password = encrypt_password(key, password)
        passwords[service] = {'guest network': guest_network, 'password': encrypted_password}
        messagebox.showinfo("Success", "Password added successfully!")
    else:
        messagebox.showwarning("Error", "Please fill in all the fields.")

def get_password():
    """
    Récupère un mot de passe de la base de données
    """
    service = service_entry.get()
    if service in passwords:
        encrypted_password = passwords[service]['password']
        decrypted_password = decrypt_password(key, encrypted_password)
        messagebox.showinfo("Password", f"Guest Network: {passwords[service]['guest network']}\nPassword: {decrypted_password}")
    else:
        messagebox.showwarning("Error", "Password not found.")

key = generate_key()

instructions = '''To add password fill all the fields and press "Add Password"
To view password, enter Account Name and press "Get Password"'''
signature = "Developed by Sai Satwik Bikumandla"

window = tk.Tk()
window.title("Password Manager")
window.configure(bg="orange")
window.resizable(False, False)

center_frame = tk.Frame(window, bg="#d3d3d3")
center_frame.grid(row=0, column=0, padx=10, pady=10)

instruction_label = tk.Label(center_frame, text=instructions, bg="#d3d3d3")
instruction_label.grid(row=0, column=1, padx=10, pady=5)

service_label = tk.Label(center_frame, text="Account:", bg="#d3d3d3")
service_label.grid(row=1, column=0, padx=10, pady
