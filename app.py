from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# database config
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# user table
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(100))

# lesson table
class Lesson(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100))
    description = db.Column(db.String(200))
    video_url = db.Column(db.String(200))

# create database
with app.app_context():
    db.create_all()

# home route
@app.route('/')
def home():
    return jsonify({
        "message": "backend is running for sign language learning app"
    })

# register route
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    name = data.get("name")
    email = data.get("email")
    password = data.get("password")

    existing_user = User.query.filter_by(email=email).first()
    if existing_user:
        return jsonify({"message": "email already exists"}), 400

    new_user = User(name=name, email=email, password=password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({
        "message": "user registered successfully",
        "name": name,
        "email": email
    }), 201

# login route ✅ (MOVED UP)
@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    email = data.get("email")
    password = data.get("password")

    user = User.query.filter_by(email=email).first()

    if user and user.password == password:
        return jsonify({
            "message": "Login successful",
            "user_id": user.id,
            "name": user.name
        })
    else:
        return jsonify({
            "message": "Invalid email or password"
        }), 401

# get lessons
@app.route('/lessons', methods=['GET'])
def get_lessons():
    lessons = Lesson.query.all()
    output = []

    for lesson in lessons:
        output.append({
            "id": lesson.id,
            "title": lesson.title,
            "description": lesson.description,
            "video_url": lesson.video_url
        })

    return jsonify({"lessons": output})

# add lesson
@app.route('/add_lesson', methods=['POST'])
def add_lesson():
    data = request.get_json()

    lesson = Lesson(
        title=data.get('title'),
        description=data.get('description'),
        video_url=data.get('video_url')
    )
    db.session.add(lesson)
    db.session.commit()

    return jsonify({"message": "Lesson added successfully"})

if __name__ == '__main__':
    app.run(debug=True)

# add predict
@app.route('/predict', methods=['POST'])
def predict():
    return "Hello from backend"