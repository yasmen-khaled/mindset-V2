<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Tasks Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50">
    <div class="min-h-screen">
        <!-- Header -->
        <header class="bg-white shadow-sm">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div class="flex items-center justify-between">
                    <div>
                        <a href="/" class="text-gray-500 hover:text-gray-700">
                            <i class="fas fa-arrow-left mr-2"></i>
                            Back to Categories
                        </a>
                        <h1 class="mt-2 text-2xl font-bold text-gray-900">{{ $category->name }} - Tasks</h1>
                    </div>
                    <button onclick="openAddTaskModal()" 
                            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200 flex items-center">
                        <i class="fas fa-plus mr-2"></i>
                        Add Task
                    </button>
                </div>
            </div>
        </header>

        <!-- Main Content -->
        <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200">
                <!-- Task List -->
                <div class="divide-y divide-gray-100" id="taskList">
                    <!-- Tasks will be loaded here -->
                </div>
            </div>
        </main>
    </div>

    <!-- Add Task Modal -->
    <div id="addTaskModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 hidden z-50">
        <div class="min-h-screen px-4 text-center">
            <div class="fixed inset-0" aria-hidden="true"></div>
            <div class="inline-block align-middle bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                    <div class="sm:flex sm:items-start">
                        <div class="mt-3 text-center sm:mt-0 sm:text-left w-full">
                            <h3 class="text-lg leading-6 font-medium text-gray-900">Add New Task</h3>
                            <div class="mt-4">
                                <form id="addTaskForm" enctype="multipart/form-data">
                                    @csrf
                                    <input type="hidden" name="category_id" value="{{ $category->id }}">
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">Task Title</label>
                                        <input type="text" name="title" required
                                               class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">Description</label>
                                        <textarea name="description" rows="3"
                                                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
                                    </div>

                                     
                                      <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">hint</label>
                                        <textarea name="hint" rows="3"
                                                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
                                    </div>
                                    
 <div class="mb-4">
    <label class="block text-sm font-medium text-gray-700">Stars</label>
    <input type="number" name="stars"
           class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
           placeholder="Enter number of stars">
</div>

 <div class="mb-4">
    <label class="block text-sm font-medium text-gray-700">Order</label>
    <input type="number" name="order_num"
           class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
           placeholder="Enter .....">
</div>


                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">Priority</label>
                                        <select name="priority"
                                                class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                            <option value="low">Low</option>
                                            <option value="medium">Medium</option>
                                            <option value="high">High</option>
                                        </select>
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">Video URL</label>
                                        <input type="url" name="video_url"
                                               class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                               placeholder="https://example.com/video">
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">Task Image (PNG only)</label>
                                        <p class="text-xs text-gray-500 mb-2">Maximum file size: 2MB. Only PNG files are allowed.</p>
                                        <div class="mt-1 flex items-center">
                                            <div id="imagePreview" class="hidden w-20 h-20 rounded-lg bg-gray-100 mr-4">
                                                <img src="" alt="Preview" class="w-full h-full object-cover rounded-lg">
                                            </div>
                                            <label class="cursor-pointer inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                                                <i class="fas fa-upload mr-2"></i>
                                                Upload Image
                                                <input type="file" name="image" accept=".png" class="hidden" onchange="previewFile(this, 'imagePreview')">
                                            </label>
                                        </div>
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-gray-700">Avatar (SVG only)</label>
                                        <p class="text-xs text-gray-500 mb-2">Maximum file size: 1MB. Only SVG files are allowed.</p>
                                        <div class="mt-1 flex items-center">
                                            <div id="avatarPreview" class="hidden w-12 h-12 rounded-full bg-gray-100 mr-4">
                                                <img src="" alt="Preview" class="w-full h-full object-cover rounded-full">
                                            </div>
                                            <label class="cursor-pointer inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                                                <i class="fas fa-upload mr-2"></i>
                                                Upload Avatar
                                                <input type="file" name="avatar" accept=".svg" class="hidden" onchange="previewFile(this, 'avatarPreview')">
                                            </label>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                    <button type="button" onclick="submitTask()"
                            class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm">
                        Save Task
                    </button>
                    <button type="button" onclick="closeAddTaskModal()"
                            class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">
                        Cancel
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            fetchTasks();
        });

        function previewFile(input, previewId) {
            const preview = document.getElementById(previewId);
            const file = input.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.querySelector('img').src = e.target.result;
                    preview.classList.remove('hidden');
                };
                reader.readAsDataURL(file);
            }
        }

        function fetchTasks() {
            fetch(`/categories/{{ $category->id }}/tasks`)
                .then(response => response.json())
                .then(tasks => {
                    const taskList = document.getElementById('taskList');
                    taskList.innerHTML = '';
                    
                    if (tasks.length === 0) {
                        taskList.innerHTML = `
                            <div class="p-8 text-center">
                                <i class="fas fa-tasks text-gray-400 text-4xl mb-4"></i>
                                <p class="text-gray-500">No tasks found for this category</p>
                                <button onclick="openAddTaskModal()" class="mt-4 text-blue-600 hover:text-blue-500">
                                    <i class="fas fa-plus mr-1"></i> Add your first task
                                </button>
                            </div>
                        `;
                        return;
                    }

                    tasks.forEach(task => {
                        const taskElement = createTaskElement(task);
                        taskList.appendChild(taskElement);
                    });
                })
                .catch(error => console.error('Error:', error));
        }

        function createTaskElement(task) {
            const div = document.createElement('div');
            div.className = 'p-6 hover:bg-gray-50 border border-gray-200 rounded-lg transition-all duration-200 hover:shadow-md';
            
            const priorityColors = {
                low: 'bg-green-100 text-green-800',
                medium: 'bg-yellow-100 text-yellow-800',
                high: 'bg-red-100 text-red-800'
            };

            div.innerHTML = `
                <div class="flex items-start space-x-4">
                    ${task.avatar ? 
                        `<img src="/storage/${task.avatar}" alt="Avatar" class="w-12 h-12 rounded-full shadow-sm">` :
                        `<div class="w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center shadow-sm">
                            <i class="fas fa-user text-gray-400"></i>
                        </div>`
                    }
                    <div class="flex-1">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-2">
                                <h3 class="text-xl font-semibold text-gray-900">${task.title}</h3>
                            </div>
                            <div class="flex items-center space-x-2">
                                <button onclick="editTask(${JSON.stringify(task).replace(/"/g, '&quot;')})" class="text-blue-600 hover:text-blue-800 p-2 rounded-full hover:bg-blue-50 transition-colors duration-200">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button onclick="deleteTask(${task.id})" class="text-red-600 hover:text-red-800 p-2 rounded-full hover:bg-red-50 transition-colors duration-200">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <p class="text-gray-600 mt-2 text-sm leading-relaxed">${task.description || ''}</p>
                        <div class="mt-3 flex flex-wrap gap-2">
                            ${task.video_url ? 
                                `<a href="${task.video_url}" target="_blank" class="inline-flex items-center text-blue-600 hover:text-blue-800 bg-blue-50 px-3 py-1 rounded-full text-sm hover:bg-blue-100 transition-colors duration-200">
                                    <i class="fas fa-video mr-1"></i> Watch Video
                                </a>` : ''
                            }
                        </div>
                        ${task.image ? 
                            `<div class="mt-4">
                                <img src="/storage/${task.image}" alt="Task Image" class="w-full max-w-md h-48 object-cover rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200">
                            </div>` : ''
                        }
                        <div class="mt-3 flex items-center space-x-2">
                            <span class="px-3 py-1 rounded-full text-xs font-medium ${priorityColors[task.priority]}">
                                ${task.priority.charAt(0).toUpperCase() + task.priority.slice(1)} Priority
                            </span>
                        </div>
                    </div>
                </div>
            `;
            return div;
        }

        function openAddTaskModal() {
            document.getElementById('addTaskModal').classList.remove('hidden');
            const form = document.getElementById('addTaskForm');
            if (!form.querySelector('input[name="task_id"]')) {
                form.reset();
                document.querySelector('#addTaskModal h3').textContent = 'Add New Task';
                document.querySelector('#addTaskModal button[type="button"]').textContent = 'Save Task';
                document.getElementById('imagePreview').classList.add('hidden');
                document.getElementById('avatarPreview').classList.add('hidden');
            }
        }

        function closeAddTaskModal() {
            document.getElementById('addTaskModal').classList.add('hidden');
        }

        function submitTask() {
            const form = document.getElementById('addTaskForm');
            const formData = new FormData(form);
            const taskId = formData.get('task_id');
            const method = taskId ? 'PUT' : 'POST';
            const url = taskId ? `/tasks/${taskId}` : '/tasks';

            // Client-side validation for files
            const imageFile = form.querySelector('input[name="image"]').files[0];
            const avatarFile = form.querySelector('input[name="avatar"]').files[0];

            if (imageFile) {
                // Check file type
                if (!imageFile.type.includes('png')) {
                    alert('Task image must be a PNG file.');
                    return;
                }
                // Check file size (2MB = 2 * 1024 * 1024 bytes)
                if (imageFile.size > 2 * 1024 * 1024) {
                    alert('Task image must be smaller than 2MB.');
                    return;
                }
            }

            if (avatarFile) {
                // Check file type
                if (!avatarFile.type.includes('svg')) {
                    alert('Avatar must be an SVG file.');
                    return;
                }
                // Check file size (1MB = 1024 * 1024 bytes)
                if (avatarFile.size > 1024 * 1024) {
                    alert('Avatar must be smaller than 1MB.');
                    return;
                }
            }

            // Add _method field for PUT request
            if (taskId) {
                formData.append('_method', 'PUT');
            }

            // Debug: Log form data
            console.log('Submitting task with data:');
            for (let [key, value] of formData.entries()) {
                if (value instanceof File) {
                    console.log(`${key}: File - ${value.name} (${value.size} bytes)`);
                } else {
                    console.log(`${key}: ${value}`);
                }
            }

            // Prepare headers - don't set Content-Type for FormData with files
            const headers = {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
            };

            fetch(url, {
                method: 'POST', // Always use POST, _method field handles the actual method
                body: formData,
                headers: headers
            })
            .then(async response => {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    let errorMsg = 'Unknown error';
                    try {
                        const data = await response.json();
                        console.log('Error response:', data);
                        if (data.errors) {
                            errorMsg = Object.values(data.errors).flat().join('\n');
                        } else if (data.message) {
                            errorMsg = data.message;
                        }
                    } catch (e) {
                        errorMsg = response.statusText;
                    }
                    alert('Failed to save task: ' + errorMsg);
                    throw new Error(errorMsg);
                }
                return response.json();
            })
            .then(data => {
                console.log('Success response:', data);
                closeAddTaskModal();
                fetchTasks();
            })
            .catch(error => console.error('Error:', error));
        }

        function deleteTask(taskId) {
            if (confirm('Are you sure you want to delete this task?')) {
                fetch(`/tasks/${taskId}`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    }
                })
                .then(response => {
                    if (response.ok) {
                        fetchTasks();
                    } else {
                        alert('Failed to delete task');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to delete task');
                });
            }
        }

        function editTask(task) {
            const form = document.getElementById('addTaskForm');
            form.title.value = task.title;
            form.description.value = task.description || '';
            form.priority.value = task.priority;
            form.video_url.value = task.video_url || '';
            
            // Add a hidden input for the task ID
            let taskIdInput = form.querySelector('input[name="task_id"]');
            if (!taskIdInput) {
                taskIdInput = document.createElement('input');
                taskIdInput.type = 'hidden';
                taskIdInput.name = 'task_id';
                form.appendChild(taskIdInput);
            }
            taskIdInput.value = task.id;

            // Show image preview if exists
            if (task.image) {
                const imagePreview = document.getElementById('imagePreview');
                imagePreview.querySelector('img').src = `/storage/${task.image}`;
                imagePreview.classList.remove('hidden');
            }

            // Show avatar preview if exists
            if (task.avatar) {
                const avatarPreview = document.getElementById('avatarPreview');
                avatarPreview.querySelector('img').src = `/storage/${task.avatar}`;
                avatarPreview.classList.remove('hidden');
            }

            openAddTaskModal();
            document.querySelector('#addTaskModal h3').textContent = 'Edit Task';
            document.querySelector('#addTaskModal button[type="button"]').textContent = 'Update Task';
        }
    </script>
</body>
</html> 