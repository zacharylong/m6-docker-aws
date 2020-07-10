import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello, Zac!"


def main():
    print("hello " + os.getenv("NAME") + " running as " + str(os.getuid()) + ")")

if __name__ == "__main__":
    main()