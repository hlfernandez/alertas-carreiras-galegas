# Creating the virtual environment

To re-create the virtual environment with the dependencies listed in the `requirements.txt` file, just run:

```
python3 -m venv .venv
pip install -r requirements.txt
```
## Saving the dependencies
```
.venv/bin/python3 -m pip freeze > requirements.txt
```