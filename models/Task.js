const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    title: {
        type: String,
        required: [true, 'Please add a title'],
        trim: true,
        maxlength: [100, 'Title cannot be more than 100 characters']
    },
    description: {
        type: String,
        required: [true, 'Please add a description'],
        trim: true
    },
    dueDate: {
        type: Date,
        required: [true, 'Please add a due date']
    },
    startTime: {
        type: String,
        required: [true, 'Please add a start time']
    },
    endTime: {
        type: String,
        required: [true, 'Please add an end time']
    },
    category: {
        type: String,
        enum: ['Idea', 'Food', 'Work', 'Sport', 'Music', 'Other'],
        default: 'Other'
    },
    completed: {
        type: Boolean,
        default: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Task', taskSchema);
