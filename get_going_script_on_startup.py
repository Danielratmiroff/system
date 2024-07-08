import subprocess
import requests
import time
import datetime


subprocess.run(['neofetch'])

# # Global variables
# script_paths = "/home/daniel/automation/"
#
# print("--------------------------------------------")
# print("Hello my dear Daniel, I'm here for you\n")
#
# # Check if today is a weekend
# today = datetime.datetime.today().weekday()
# if today >= 5:  # 5 = Saturday, 6 = Sunday
#     print("It's weekend! Wanna work? (yes/y) default is no")
#     choice = input("Your choice: ").strip().lower()
#     if choice not in ['yes', 'y']:
#         print("Enjoy your weekend! Love you!")
#         exit()
#
# print("Let's work!")
# print("I'm gonna open your work applications for you.")
#
# # Show a loading timer of 5 seconds
# timer = 15
# print(f"Starting in {timer} seconds...")
# for i in range(timer, 0, -1):
#     print(f"{'*' * (6 - i)} {i}...")
#     time.sleep(1)
#
# print("Starting work...")
# subprocess.run(['fish', '-c', 'work start'])
#
# url = "https://api.quotable.io/random"
# response = requests.get(url)
# if response.status_code == 200:
#     print("--------------------------------------------")
#     print("----------------------------------")
#     print("------------------------")
#     print("--------------")
#     print("-----")
#     print(response.json()['content'])
#     print("- " + response.json()['author'])
#     print("-----")
#     print("--------------")
#     print("------------------------")
#     print("----------------------------------")
#     print("--------------------------------------------")
#
print("Have a good day! Love you!")
