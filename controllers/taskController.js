const Task = require('../models/Task');
const ErrorResponse = require('../utils/errorResponse');
const asyncHandler = require('../middleware/async');

// @desc    Get all tasks
// @route   GET /api/tasks
// @access  Private
exports.getTasks = asyncHandler(async (req, res, next) => {
    // Filter tasks by user and date range if provided
    let query = { user: req.user.id };
    
    // Check if date range is provided
    if (req.query.startDate && req.query.endDate) {
        query.dueDate = {
            $gte: new Date(req.query.startDate),
            $lte: new Date(req.query.endDate)
        };
    } else if (req.query.date) {
        // Get tasks for a specific date
        const startOfDay = new Date(req.query.date);
        startOfDay.setHours(0, 0, 0, 0);
        
        const endOfDay = new Date(req.query.date);
        endOfDay.setHours(23, 59, 59, 999);
        
        query.dueDate = {
            $gte: startOfDay,
            $lte: endOfDay
        };
    }
    
    // Filter by category if provided
    if (req.query.category) {
        query.category = req.query.category;
    }
    
    // Filter by completion status if provided
    if (req.query.completed !== undefined) {
        query.completed = req.query.completed === 'true';
    }

    const tasks = await Task.find(query).sort({ dueDate: 1, startTime: 1 });
    
    res.status(200).json({
        success: true,
        count: tasks.length,
        data: tasks
    });
});

// @desc    Get single task
// @route   GET /api/tasks/:id
// @access  Private
exports.getTask = asyncHandler(async (req, res, next) => {
    const task = await Task.findById(req.params.id);

    if (!task) {
        return next(
            new ErrorResponse(`Task not found with id of ${req.params.id}`, 404)
        );
    }

    // Make sure user owns the task
    if (task.user.toString() !== req.user.id) {
        return next(
            new ErrorResponse(`Not authorized to access this task`, 401)
        );
    }

    res.status(200).json({
        success: true,
        data: task
    });
});

// @desc    Create task
// @route   POST /api/tasks
// @access  Private
exports.createTask = asyncHandler(async (req, res, next) => {
    // Add user to req.body
    req.body.user = req.user.id;

    const task = await Task.create(req.body);

    res.status(201).json({
        success: true,
        data: task
    });
});

// @desc    Update task
// @route   PUT /api/tasks/:id
// @access  Private
exports.updateTask = asyncHandler(async (req, res, next) => {
    let task = await Task.findById(req.params.id);

    if (!task) {
        return next(
            new ErrorResponse(`Task not found with id of ${req.params.id}`, 404)
        );
    }

    // Make sure user owns the task
    if (task.user.toString() !== req.user.id) {
        return next(
            new ErrorResponse(`Not authorized to update this task`, 401)
        );
    }

    // Update task
    task = await Task.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
    });

    res.status(200).json({
        success: true,
        data: task
    });
});

// @desc    Delete task
// @route   DELETE /api/tasks/:id
// @access  Private
exports.deleteTask = asyncHandler(async (req, res, next) => {
    const task = await Task.findById(req.params.id);

    if (!task) {
        return next(
            new ErrorResponse(`Task not found with id of ${req.params.id}`, 404)
        );
    }

    // Make sure user owns the task
    if (task.user.toString() !== req.user.id) {
        return next(
            new ErrorResponse(`Not authorized to delete this task`, 401)
        );
    }

    await Task.findByIdAndDelete(req.params.id);

    res.status(200).json({
        success: true,
        data: {}
    });
});

// @desc    Toggle task completion status
// @route   PUT /api/tasks/:id/toggle
// @access  Private
exports.toggleTaskCompletion = asyncHandler(async (req, res, next) => {
    const task = await Task.findById(req.params.id);

    if (!task) {
        return next(
            new ErrorResponse(`Task not found with id of ${req.params.id}`, 404)
        );
    }

    // Make sure user owns the task
    if (task.user.toString() !== req.user.id) {
        return next(
            new ErrorResponse(`Not authorized to update this task`, 401)
        );
    }

    // Toggle completion status
    task.completed = !task.completed;
    await task.save();

    res.status(200).json({
        success: true,
        data: task
    });
});
