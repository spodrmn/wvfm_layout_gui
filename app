import os
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import requests

# Load API key securely from environment variable
API_KEY = os.getenv("OPENROUTER_API_KEY")

def chat_with_deepseek(user_input):
    if not API_KEY:
        return "Error: API key not found. Please set the OPENROUTER_API_KEY environment variable."

    response = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost",
        },
        json={
            "model": "deepseek/deepseek-r1:free",
            "messages": [
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": user_input}
            ]
        }
    )

    if response.status_code == 200:
        data = response.json()
        return data['choices'][0]['message']['content']
    else:
        return f"Error: {response.status_code} - {response.text}"

def get_recommendations():
    user_input = search_bar.get()
    if not user_input.strip():
        update_output("Please enter a valid input.")
        return

    prompt = f"Recommend me three (3) songs based on my entry, {user_input}. Base these recommendations on mood, genre fit, lyrical relevance, replayability, and a standout “wow” factor. Print the response numerically (1-3), with a bullet underneath each number briefly explaining why."
    response = chat_with_deepseek(prompt)
    update_output(response)

def update_output(content):
    logo_label.pack_forget()
    output_field.pack(fill="both", expand=True)
    output_field.config(state=tk.NORMAL)
    output_field.delete("1.0", tk.END)
    output_field.insert(tk.END, content)
    output_field.config(state=tk.DISABLED)

# Logo setup
script_dir = os.path.dirname(os.path.abspath(__file__))
logo_path = os.path.join(script_dir, "logo.png")

root = tk.Tk()
root.title("WVFM Music Recommendation")
root.geometry("600x600")
root.resizable(False, False)
root.configure(bg="#F8F5F2")

logo_frame = ttk.Frame(root, padding="10 10 10 10", style="Main.TFrame")
logo_frame.pack(fill="both", expand=True)

try:
    logo_image = Image.open(logo_path)
    logo_image = logo_image.resize((400, 400), Image.Resampling.LANCZOS)
    logo_photo = ImageTk.PhotoImage(logo_image)
    logo_label = tk.Label(logo_frame, image=logo_photo, bg="#F8F5F2")
    logo_label.pack()
except FileNotFoundError:
    print(f"Error: The logo file was not found at {logo_path}")
    logo_label = tk.Label(logo_frame, text="Logo Not Found", bg="#F8F5F2", fg="#FF3B3F")
    logo_label.pack()

output_field = tk.Text(logo_frame, wrap=tk.WORD, font=("Helvetica", 12), bg="#F8F5F2", fg="#000000", insertbackground="#FF3B3F")
output_field.pack_forget()

search_frame = ttk.Frame(root, style="Main.TFrame")
search_frame.pack(fill="x", padx=10, pady=10)

search_bar = ttk.Entry(search_frame, font=("Helvetica", 14))
search_bar.pack(side="left", fill="x", expand=True, padx=5)

enter_button = ttk.Button(search_frame, text="Enter", command=get_recommendations, style="WVFM.TButton")
enter_button.pack(side="right", padx=5)

style = ttk.Style()
style.configure("Main.TFrame", background="#F8F5F2")
style.configure("WVFM.TButton", background="#FF3B3F", foreground="white", font=("Helvetica", 12, "bold"), padding=10)

root.mainloop()
