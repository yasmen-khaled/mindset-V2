<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Category Management</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .sidebar-item.active {
            background-color: #3b82f6;
            color: white;
        }
        .category-card {
            transition: transform 0.2s ease-in-out;
        }
        .category-card:hover {
            transform: translateY(-5px);
        }
        .modal-overlay {
            backdrop-filter: blur(5px);
        }
    </style>
</head>
<body class="bg-gray-50">
    <div class="flex h-screen">
        <!-- Sidebar -->
        <div class="w-64 bg-white shadow-lg">
            <div class="p-6">
                <h1 class="text-2xl font-bold text-gray-800">Categories</h1>
                <p class="text-sm text-gray-500 mt-1">Management System</p>
            </div>
            <nav class="mt-4">
                <div class="px-4 py-2">
                    <h2 class="text-xs uppercase tracking-wide text-gray-500 font-semibold">Levels</h2>
                </div>
                <ul class="space-y-1 px-3">
                    @for ($i = 1; $i <= 8; $i++)
                    <li>
                        <button onclick="switchLevel({{ $i }})" 
                                data-level="{{ $i }}"
                                class="sidebar-item w-full px-4 py-2 rounded-lg text-left transition-colors duration-200 hover:bg-blue-50 hover:text-blue-600 flex items-center space-x-3">
                            <i class="fas fa-layer-group"></i>
                            <span>Level {{ $i }}</span>
                        </button>
                    </li>
                    @endfor
                </ul>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="flex-1 overflow-auto">
            <div class="p-8">
                <!-- Header -->
                <div class="flex justify-between items-center mb-8">
                    <div>
                        <h2 class="text-3xl font-bold text-gray-800">Level <span id="currentLevel">1</span></h2>
                        <p class="text-gray-500 mt-1">Manage categories for this level</p>
                    </div>
                    <div class="flex space-x-3">
                        <button onclick="openQuizModal()" 
                                class="flex items-center space-x-2 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors duration-200 shadow-md hover:shadow-lg">
                            <i class="fas fa-question-circle"></i>
                            <span>Manage Quiz</span>
                        </button>
                        <button onclick="openAddCategoryModal()" 
                                class="flex items-center space-x-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200 shadow-md hover:shadow-lg">
                            <i class="fas fa-plus"></i>
                            <span>Add Category</span>
                        </button>
                    </div>
                </div>

                <!-- Category Grid -->
                <div id="categoryList" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    <!-- Categories will be loaded here -->
                </div>
            </div>
        </div>
    </div>

    <!-- Add Category Modal -->
    <div id="addCategoryModal" class="fixed inset-0 modal-overlay bg-gray-900 bg-opacity-50 hidden z-50">
        <div class="min-h-screen px-4 text-center">
            <div class="fixed inset-0" aria-hidden="true"></div>
            <div class="inline-block align-middle max-w-md w-full p-4 my-8 overflow-hidden text-left transition-all transform bg-white shadow-xl rounded-xl">
                <div class="absolute top-2 right-2">
                    <button onclick="closeAddCategoryModal()" class="text-gray-400 hover:text-gray-500">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                
                <div class="mb-4">
                    <h3 class="text-xl font-bold text-gray-900">Add New Category</h3>
                    <p class="mt-1 text-sm text-gray-500">Level <span id="modalLevel">1</span></p>
                </div>

                <form id="addCategoryForm" class="space-y-4">
                    @csrf
                    <input type="hidden" name="level" id="category_level" value="1">
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Category Name</label>
                        <input type="text" name="name" required
                               class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Image</label>
                        <div class="flex items-center space-x-4">
                            <div class="flex-shrink-0">
                                <div id="imagePreview" class="hidden w-20 h-20 rounded-lg bg-gray-100 flex items-center justify-center">
                                    <img src="" alt="Preview" class="w-full h-full object-cover rounded-lg">
                                </div>
                                <div id="imagePlaceholder" class="w-20 h-20 rounded-lg bg-gray-100 flex items-center justify-center">
                                    <i class="fas fa-image text-gray-400 text-2xl"></i>
                                </div>
                            </div>
                            <div class="flex-1">
                                <input type="file" name="image" id="image" accept="image/*" class="hidden" onchange="previewImage(this)">
                                <label for="image" class="cursor-pointer inline-flex items-center px-3 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                                    <i class="fas fa-upload mr-2"></i>
                                    Upload Image
                                </label>
                            </div>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Options</label>
                        <div id="optionsContainer" class="mt-2 space-y-2"></div>
                        <button type="button" onclick="addOption()" 
                                class="mt-2 inline-flex items-center text-sm text-blue-600 hover:text-blue-500">
                            <i class="fas fa-plus mr-1"></i>
                            Add Option
                        </button>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                        <select name="status" class="block w-full pl-3 pr-10 py-2 text-base border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>

                    <div class="flex justify-end space-x-2 pt-4 border-t">
                        <button type="button" onclick="closeAddCategoryModal()" 
                                class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-gray-500">
                            Cancel
                        </button>
                        <button type="submit" 
                                class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            Save Category
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Category Modal -->
    <div id="editCategoryModal" class="fixed inset-0 modal-overlay bg-gray-900 bg-opacity-50 hidden z-50">
        <div class="min-h-screen px-4 text-center">
            <div class="fixed inset-0" aria-hidden="true"></div>
            <div class="inline-block align-middle max-w-md w-full p-4 my-8 overflow-hidden text-left transition-all transform bg-white shadow-xl rounded-xl">
                <div class="absolute top-2 right-2">
                    <button onclick="closeEditCategoryModal()" class="text-gray-400 hover:text-gray-500">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                
                <div class="mb-4">
                    <h3 class="text-xl font-bold text-gray-900">Edit Category</h3>
                    <p class="mt-1 text-sm text-gray-500">Level <span id="editModalLevel">1</span></p>
                </div>

                <form id="editCategoryForm" class="space-y-4">
                    @csrf
                    @method('PUT')
                    <input type="hidden" name="level" id="edit_category_level" value="1">
                    <input type="hidden" name="category_id" id="edit_category_id">
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Category Name</label>
                        <input type="text" name="name" id="edit_category_name" required
                               class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Image</label>
                        <div class="flex items-center space-x-4">
                            <div class="flex-shrink-0">
                                <div id="editImagePreview" class="hidden w-20 h-20 rounded-lg bg-gray-100 flex items-center justify-center">
                                    <img src="" alt="Preview" class="w-full h-full object-cover rounded-lg">
                                </div>
                                <div id="editImagePlaceholder" class="w-20 h-20 rounded-lg bg-gray-100 flex items-center justify-center">
                                    <i class="fas fa-image text-gray-400 text-2xl"></i>
                                </div>
                            </div>
                            <div class="flex-1">
                                <input type="file" name="image" id="edit_image" accept="image/*" class="hidden" onchange="previewEditImage(this)">
                                <label for="edit_image" class="cursor-pointer inline-flex items-center px-3 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                                    <i class="fas fa-upload mr-2"></i>
                                    Change Image
                                </label>
                            </div>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Options</label>
                        <div id="editOptionsContainer" class="mt-2 space-y-2"></div>
                        <button type="button" onclick="addEditOption()" 
                                class="mt-2 inline-flex items-center text-sm text-blue-600 hover:text-blue-500">
                            <i class="fas fa-plus mr-1"></i>
                            Add Option
                        </button>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                        <select name="status" id="edit_category_status" class="block w-full pl-3 pr-10 py-2 text-base border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>

                    <div class="flex justify-end space-x-2 pt-4 border-t">
                        <button type="button" onclick="closeEditCategoryModal()" 
                                class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-gray-500">
                            Cancel
                        </button>
                        <button type="submit" 
                                class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            Update Category
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Quiz Management Modal -->
    <div id="quizModal" class="fixed inset-0 modal-overlay bg-gray-900 bg-opacity-50 hidden z-50">
        <div class="min-h-screen px-4 text-center">
            <div class="fixed inset-0" aria-hidden="true"></div>
            <div class="inline-block align-middle max-w-3xl w-full p-6 my-8 overflow-hidden text-left transition-all transform bg-white shadow-xl rounded-xl">
                <div class="absolute top-2 right-2">
                    <button onclick="closeQuizModal()" class="text-gray-400 hover:text-gray-500">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                
                <div class="mb-6">
                    <h3 class="text-2xl font-bold text-gray-900">Quiz Management</h3>
                    <p class="mt-1 text-sm text-gray-500">Add quiz questions for Level <span id="quizModalLevel">1</span></p>
                </div>

                <div class="space-y-6">
                    <!-- Category Selection -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">Select Category</label>
                        <select id="quizCategory" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                            <!-- Categories will be loaded here -->
                        </select>
                    </div>

                    <!-- Questions List -->
                    <div id="questionsList" class="space-y-4">
                        <!-- Existing questions will be shown here -->
                    </div>

                    <!-- Add Question Form -->
                    <form id="addQuestionForm" class="space-y-4 border-t pt-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Question</label>
                            <textarea id="questionText" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500"></textarea>
                        </div>

                        <!-- Options -->
                        <div class="space-y-3">
                            <label class="block text-sm font-medium text-gray-700">Options</label>
                            <div class="space-y-2" id="quizOptionsContainer">
                                <div class="flex items-center space-x-2">
                                    <input type="radio" name="correct" value="0" class="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300">
                                    <input type="text" placeholder="Option 1" class="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                                </div>
                                <div class="flex items-center space-x-2">
                                    <input type="radio" name="correct" value="1" class="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300">
                                    <input type="text" placeholder="Option 2" class="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                                </div>
                            </div>
                            <button type="button" onclick="addQuizOption()" class="text-sm text-purple-600 hover:text-purple-500">
                                <i class="fas fa-plus"></i> Add Option
                            </button>
                        </div>

                        <div class="flex justify-end space-x-3">
                            <button type="button" id="cancelEditBtn" onclick="cancelEdit()" 
                                    class="px-4 py-2 bg-gray-500 text-white text-sm font-medium rounded-md hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 hidden">
                                Cancel Edit
                            </button>
                            <button type="button" onclick="addQuestion()" 
                                    class="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500">
                                Add Question
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentLevel = 1;

        document.addEventListener('DOMContentLoaded', function() {
            switchLevel(1);
            setupFormSubmission();
            setupEditFormSubmission();
            updateActiveSidebarItem(1);
        });

        function updateActiveSidebarItem(level) {
            document.querySelectorAll('.sidebar-item').forEach(item => {
                item.classList.remove('active');
                if (item.dataset.level == level) {
                    item.classList.add('active');
                }
            });
        }

        function switchLevel(level) {
            currentLevel = level;
            document.getElementById("currentLevel").innerText = level;
            updateActiveSidebarItem(level);
            fetchCategories(level);
        }

        function fetchCategories(level) {
            fetch(`/categories?level=${level}`)
                .then(response => response.json())
                .then(categories => {
                    const categoryList = document.getElementById("categoryList");
                    categoryList.innerHTML = '';
                    
                    if (categories.length === 0) {
                        categoryList.innerHTML = `
                            <div class="col-span-full flex flex-col items-center justify-center p-8 bg-white rounded-lg border-2 border-dashed border-gray-200">
                                <i class="fas fa-folder-open text-gray-400 text-4xl mb-3"></i>
                                <p class="text-gray-500">No categories found for this level</p>
                                <button onclick="openAddCategoryModal()" class="mt-4 text-blue-600 hover:text-blue-500">
                                    <i class="fas fa-plus mr-1"></i> Add your first category
                                </button>
                            </div>
                        `;
                        return;
                    }
                    
                    categories.forEach(category => {
                        const card = createCategoryCard(category);
                        categoryList.appendChild(card);
                    });
                })
                .catch(error => console.error('Error:', error));
        }

        function createCategoryCard(category) {
            const div = document.createElement('div');
            div.className = 'category-card bg-white rounded-xl shadow-md overflow-hidden cursor-pointer relative';
            div.onclick = function(e) {
                // Prevent navigation if clicking the delete or edit button
                if (e.target.closest('.delete-btn') || e.target.closest('.edit-btn')) {
                    return;
                }
                window.location.href = `/categories/${category.id}/manage-tasks`;
            };
            div.innerHTML = `
                <div class="relative">
                    ${category.image ? 
                        `<img src="/storage/${category.image}" alt="${category.name}" class="w-full h-48 object-cover">` :
                        `<div class="w-full h-48 bg-gray-100 flex items-center justify-center">
                            <i class="fas fa-image text-gray-400 text-4xl"></i>
                        </div>`
                    }
                    <div class="absolute top-2 right-2 flex space-x-2">
                        <button onclick="editCategory(${JSON.stringify(category).replace(/"/g, '&quot;')})" 
                                class="edit-btn p-2 bg-blue-500 bg-opacity-75 text-white rounded-full hover:bg-opacity-100 transition-opacity duration-200">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button onclick="deleteCategory(${category.id})" 
                                class="delete-btn p-2 bg-red-500 bg-opacity-75 text-white rounded-full hover:bg-opacity-100 transition-opacity duration-200">
                            <i class="fas fa-trash-alt"></i>
                        </button>
                    </div>
                </div>
                <div class="p-4">
                    <h3 class="text-lg font-semibold text-gray-800 mb-2">${category.name}</h3>
                    ${category.options && category.options.length > 0 ? `
                        <div class="space-y-1 mb-3">
                            ${category.options.map(option => 
                                `<span class="inline-block px-2 py-1 text-sm bg-gray-100 text-gray-700 rounded-full mr-2 mb-2">
                                    ${option}
                                </span>`
                            ).join('')}
                        </div>
                    ` : ''}
                    <div class="flex items-center justify-between mt-2">
                        <span class="px-2 py-1 text-xs rounded-full ${
                            category.status ? 
                            'bg-green-100 text-green-800' : 
                            'bg-red-100 text-red-800'
                        }">
                            ${category.status ? 'Active' : 'Inactive'}
                        </span>
                        <span class="text-blue-600 hover:text-blue-700">
                            <i class="fas fa-tasks mr-1"></i>
                            Manage Tasks
                        </span>
                    </div>
                </div>
            `;
            return div;
        }

        function openAddCategoryModal() {
            document.getElementById("addCategoryModal").classList.remove("hidden");
            document.getElementById("addCategoryForm").reset();
            document.getElementById("optionsContainer").innerHTML = "";
            document.getElementById("imagePreview").classList.add("hidden");
            document.getElementById("imagePlaceholder").classList.remove("hidden");
            document.getElementById("category_level").value = currentLevel;
            document.getElementById("modalLevel").innerText = currentLevel;
        }

        function closeAddCategoryModal() {
            document.getElementById("addCategoryModal").classList.add("hidden");
        }

        function addOption() {
            const container = document.getElementById("optionsContainer");
            const optionDiv = document.createElement("div");
            optionDiv.className = "flex items-center space-x-2";
            optionDiv.innerHTML = `
                <input type="text" name="options[]" placeholder="Enter option"
                       class="flex-1 px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                <button type="button" onclick="this.parentElement.remove()" 
                        class="text-red-500 hover:text-red-700">
                    <i class="fas fa-times"></i>
                </button>
            `;
            container.appendChild(optionDiv);
        }

        function previewImage(input) {
            const preview = document.getElementById("imagePreview");
            const placeholder = document.getElementById("imagePlaceholder");
            const previewImg = preview.querySelector("img");
            
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    previewImg.src = e.target.result;
                    preview.classList.remove("hidden");
                    placeholder.classList.add("hidden");
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function setupFormSubmission() {
            document.getElementById("addCategoryForm").addEventListener("submit", function(e) {
                e.preventDefault();
                const imageInput = document.getElementById('image');
                if (imageInput.files.length > 0) {
                    const imageFile = imageInput.files[0];
                    if (!imageFile.type.startsWith('image/')) {
                        alert('Please upload an image file.');
                        return;
                    }
                    if (imageFile.size > 2048 * 1024) {
                        alert('Image size must be less than 2MB.');
                        return;
                    }
                }
                const formData = new FormData(this);
                fetch('/categories', {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    }
                })
                .then(async response => {
                    if (!response.ok) {
                        let errorMsg = 'Unknown error';
                        try {
                            const data = await response.json();
                            if (data.errors) {
                                errorMsg = Object.values(data.errors).flat().join('\n');
                            } else if (data.message) {
                                errorMsg = data.message;
                            }
                        } catch (e) {
                            errorMsg = response.statusText;
                        }
                        alert('Failed to add category: ' + errorMsg);
                        throw new Error(errorMsg);
                    }
                    return response.json();
                })
                .then(data => {
                    closeAddCategoryModal();
                    fetchCategories(currentLevel);
                })
                .catch(error => console.error('Error:', error));
            });
        }

        function deleteCategory(id) {
            if (confirm('Are you sure you want to delete this category?')) {
                fetch(`/categories/${id}`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    }
                })
                .then(response => {
                    if (response.ok) {
                        fetchCategories(currentLevel);
                    } else {
                        alert('Failed to delete category');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to delete category');
                });
            }
        }

        function editCategory(category) {
            document.getElementById("editCategoryModal").classList.remove("hidden");
            document.getElementById("edit_category_id").value = category.id;
            document.getElementById("edit_category_name").value = category.name;
            document.getElementById("edit_category_level").value = category.level;
            document.getElementById("edit_category_status").value = category.status ? "1" : "0";
            document.getElementById("editModalLevel").innerText = category.level;

            // Clear and populate options
            const optionsContainer = document.getElementById("editOptionsContainer");
            optionsContainer.innerHTML = "";
            if (category.options) {
                category.options.forEach(option => addEditOption(option));
            }

            // Show image preview if exists
            const imagePreview = document.getElementById("editImagePreview");
            const imagePlaceholder = document.getElementById("editImagePlaceholder");
            if (category.image) {
                imagePreview.querySelector("img").src = `/storage/${category.image}`;
                imagePreview.classList.remove("hidden");
                imagePlaceholder.classList.add("hidden");
            } else {
                imagePreview.classList.add("hidden");
                imagePlaceholder.classList.remove("hidden");
            }
        }

        function closeEditCategoryModal() {
            document.getElementById("editCategoryModal").classList.add("hidden");
        }

        function previewEditImage(input) {
            const preview = document.getElementById("editImagePreview");
            const placeholder = document.getElementById("editImagePlaceholder");
            const previewImg = preview.querySelector("img");
            
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    previewImg.src = e.target.result;
                    preview.classList.remove("hidden");
                    placeholder.classList.add("hidden");
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function addEditOption(value = '') {
            const container = document.getElementById("editOptionsContainer");
            const optionDiv = document.createElement("div");
            optionDiv.className = "flex items-center space-x-2";
            optionDiv.innerHTML = `
                <input type="text" name="options[]" value="${value}" placeholder="Enter option"
                       class="flex-1 px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                <button type="button" onclick="this.parentElement.remove()" 
                        class="text-red-500 hover:text-red-700">
                    <i class="fas fa-times"></i>
                </button>
            `;
            container.appendChild(optionDiv);
        }

        function setupEditFormSubmission() {
            document.getElementById("editCategoryForm").addEventListener("submit", function(e) {
                e.preventDefault();
                const formData = new FormData(this);
                const categoryId = formData.get('category_id');
                
                // Add _method field for PUT request
                formData.append('_method', 'PUT');

                fetch(`/categories/${categoryId}`, {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    }
                })
                .then(async response => {
                    if (!response.ok) {
                        let errorMsg = 'Unknown error';
                        try {
                            const data = await response.json();
                            if (data.errors) {
                                errorMsg = Object.values(data.errors).flat().join('\n');
                            } else if (data.message) {
                                errorMsg = data.message;
                            }
                        } catch (e) {
                            errorMsg = response.statusText;
                        }
                        alert('Failed to update category: ' + errorMsg);
                        throw new Error(errorMsg);
                    }
                    return response.json();
                })
                .then(data => {
                    closeEditCategoryModal();
                    fetchCategories(currentLevel);
                })
                .catch(error => console.error('Error:', error));
            });
        }

        function createTestCategories() {
            const testCategories = [
                {
                    name: "Test Category 1",
                    options: ["Option 1", "Option 2", "Option 3"],
                    status: 1
                },
                {
                    name: "Test Category 2",
                    options: ["Test A", "Test B", "Test C"],
                    status: 1
                },
                {
                    name: "Test Category 3",
                    options: ["Sample 1", "Sample 2"],
                    status: 1
                }
            ];

            let completedCount = 0;
            const totalCategories = testCategories.length;

            testCategories.forEach(category => {
                const formData = new FormData();
                formData.append('name', category.name);
                formData.append('level', currentLevel);
                formData.append('status', category.status);
                category.options.forEach(option => {
                    formData.append('options[]', option);
                });

                fetch('/categories', {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    }
                })
                .then(response => response.json())
                .then(data => {
                    completedCount++;
                    if (completedCount === totalCategories) {
                        fetchCategories(currentLevel);
                        alert('Test categories have been created successfully!');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to create test categories. Please try again.');
                });
            });
        }

        function openQuizModal() {
            document.getElementById('quizModal').classList.remove('hidden');
            document.getElementById('quizModalLevel').textContent = currentLevel;
            resetQuizForm();
            loadCategoriesForQuiz();
        }

        function resetQuizForm() {
            document.getElementById('questionText').value = '';
            const optionsContainer = document.getElementById('quizOptionsContainer');
            optionsContainer.innerHTML = `
                <div class="flex items-center space-x-2">
                    <input type="radio" name="correct" value="0" class="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300">
                    <input type="text" placeholder="Option 1" class="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                </div>
                <div class="flex items-center space-x-2">
                    <input type="radio" name="correct" value="1" class="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300">
                    <input type="text" placeholder="Option 2" class="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                </div>
            `;
            
            // Clear edit mode
            document.getElementById('addQuestionForm').removeAttribute('data-edit-question-id');
            document.querySelector('#addQuestionForm button[onclick="addQuestion()"]').textContent = 'Add Question';
            
            // Hide cancel edit button
            document.getElementById('cancelEditBtn').classList.add('hidden');
        }

        function closeQuizModal() {
            document.getElementById('quizModal').classList.add('hidden');
        }

        function loadCategoriesForQuiz() {
            console.log('Loading categories for quiz, level:', currentLevel);
            const select = document.getElementById('quizCategory');
            select.innerHTML = '';
            
            fetch(`/categories?level=${currentLevel}`)
                .then(response => {
                    console.log('Categories response status:', response.status);
                    return response.json();
                })
                .then(categories => {
                    console.log('Categories loaded:', categories);
                    categories.forEach(category => {
                        const option = document.createElement('option');
                        option.value = category.id;
                        option.textContent = category.name;
                        select.appendChild(option);
                    });
                    if (categories.length > 0) {
                        console.log('Loading questions for first category:', categories[0].id);
                        loadQuestionsForCategory(categories[0].id);
                    } else {
                        console.log('No categories found for this level');
                    }
                })
                .catch(error => {
                    console.error('Error loading categories:', error);
                });
        }

        function loadQuestionsForCategory(categoryId) {
            const questionsList = document.getElementById('questionsList');
            questionsList.innerHTML = '<div class="text-center py-4">Loading questions...</div>';
            
            fetch(`/categories/${categoryId}/questions`)
                .then(response => response.json())
                .then(questions => {
                    questionsList.innerHTML = '';
                    questions.forEach(question => {
                        const questionElement = createQuestionElement(question);
                        questionsList.appendChild(questionElement);
                    });
                    if (questions.length === 0) {
                        questionsList.innerHTML = '<div class="text-center py-4 text-gray-500">No questions added yet</div>';
                    }
                });
        }

        function createQuestionElement(question) {
            const div = document.createElement('div');
            div.className = 'bg-gray-50 p-4 rounded-lg';
            div.innerHTML = `
                <div class="flex justify-between items-start">
                    <div class="flex-1">
                        <p class="font-medium">${question.text}</p>
                        <div class="mt-2 space-y-1">
                            ${question.options.map((option, index) => `
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm ${option.isCorrect ? 'text-green-600 font-medium' : 'text-gray-600'}">
                                        ${option.isCorrect ? '✓' : '○'} ${option.text}
                                    </span>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                    <div class="flex items-center space-x-2">
                        <button onclick="editQuestion(${JSON.stringify(question).replace(/"/g, '&quot;')})" class="text-blue-500 hover:text-blue-700">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button onclick="deleteQuestion(${question.id})" class="text-red-500 hover:text-red-700">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            `;
            return div;
        }

        function addQuizOption() {
            console.log('addQuizOption function called');
            const container = document.getElementById('quizOptionsContainer');
            console.log('Options container:', container);
            
            if (!container) {
                console.error('Options container not found!');
                return;
            }
            
            const optionCount = container.children.length;
            console.log('Current option count:', optionCount);
            
            const div = document.createElement('div');
            div.className = 'flex items-center space-x-2';
            div.innerHTML = `
                <input type="radio" name="correct" value="${optionCount}" class="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300">
                <input type="text" placeholder="Option ${optionCount + 1}" class="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                <button type="button" onclick="removeQuizOption(this)" class="text-red-500 hover:text-red-700">
                    <i class="fas fa-times"></i>
                </button>
            `;
            container.appendChild(div);
            console.log('Option added successfully');
        }

        function removeQuizOption(button) {
            const optionDiv = button.parentElement;
            optionDiv.remove();
            // Reindex the remaining radio buttons
            const container = document.getElementById('quizOptionsContainer');
            container.querySelectorAll('input[type="radio"]').forEach((radio, index) => {
                radio.value = index;
            });
        }

        function addQuestion() {
            const categoryId = document.getElementById('quizCategory').value;
            const questionText = document.getElementById('questionText').value;
            const optionsContainer = document.getElementById('quizOptionsContainer');
            const options = [];
            let correctAnswerIndex = -1;
            const editQuestionId = document.getElementById('addQuestionForm').getAttribute('data-edit-question-id');

            console.log('Adding/updating question for category:', categoryId);
            console.log('Question text:', questionText);
            console.log('Edit question ID:', editQuestionId);

            // Gather options and find correct answer
            const optionDivs = optionsContainer.querySelectorAll('.flex');
            console.log('Found option divs:', optionDivs.length);
            
            optionDivs.forEach((optionDiv, index) => {
                const optionText = optionDiv.querySelector('input[type="text"]').value;
                const radioButton = optionDiv.querySelector('input[type="radio"]');
                const isCorrect = radioButton.checked;
                
                console.log(`Option ${index}:`, optionText, 'Correct:', isCorrect);
                
                options.push({
                    text: optionText,
                    isCorrect: isCorrect
                });
                
                if (isCorrect) {
                    correctAnswerIndex = index;
                }
            });

            console.log('All options:', options);
            console.log('Correct answer index:', correctAnswerIndex);

            // Validate inputs
            if (!questionText.trim()) {
                alert('Please enter a question');
                return;
            }
            if (options.length < 2) {
                alert('Please add at least 2 options');
                return;
            }
            if (correctAnswerIndex === -1) {
                alert('Please select a correct answer');
                return;
            }

            // Check for empty option texts
            const emptyOptions = options.filter(option => !option.text.trim());
            if (emptyOptions.length > 0) {
                alert('Please fill in all option texts');
                return;
            }

            console.log('Validation passed, sending to server...');

            // Determine if this is an add or update operation
            const method = editQuestionId ? 'PUT' : 'POST';
            const url = editQuestionId ? `/categories/${categoryId}/questions/${editQuestionId}` : `/categories/${categoryId}/questions`;

            // Send to server
            fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({
                    text: questionText,
                    options: options
                })
            })
            .then(response => {
                console.log('Server response status:', response.status);
                return response.json();
            })
            .then(data => {
                console.log('Server response data:', data);
                
                // Reset form
                resetQuizForm();
                
                // Reload questions
                loadQuestionsForCategory(categoryId);
                alert(editQuestionId ? 'Question updated successfully!' : 'Question added successfully!');
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to save question. Please try again.');
            });
        }

        function deleteQuestion(questionId) {
            if (confirm('Are you sure you want to delete this question?')) {
                const categoryId = document.getElementById('quizCategory').value;
                fetch(`/categories/${categoryId}/questions/${questionId}`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    }
                })
                .then(response => {
                    if (response.ok) {
                        loadQuestionsForCategory(categoryId);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to delete question. Please try again.');
                });
            }
        }

        // Add event listener for category selection change
        document.getElementById('quizCategory')?.addEventListener('change', function() {
            loadQuestionsForCategory(this.value);
        });

        function editQuestion(question) {
            console.log('Editing question:', question);
            
            // Set form to edit mode
            document.getElementById('questionText').value = question.text;
            
            // Clear and populate options
            const optionsContainer = document.getElementById('quizOptionsContainer');
            optionsContainer.innerHTML = '';
            
            question.options.forEach((option, index) => {
                const div = document.createElement('div');
                div.className = 'flex items-center space-x-2';
                div.innerHTML = `
                    <input type="radio" name="correct" value="${index}" ${option.isCorrect ? 'checked' : ''} class="focus:ring-purple-500 h-4 w-4 text-purple-600 border-gray-300">
                    <input type="text" value="${option.text}" placeholder="Option ${index + 1}" class="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500">
                    <button type="button" onclick="removeQuizOption(this)" class="text-red-500 hover:text-red-700">
                        <i class="fas fa-times"></i>
                    </button>
                `;
                optionsContainer.appendChild(div);
            });
            
            // Store the question ID for editing
            document.getElementById('addQuestionForm').setAttribute('data-edit-question-id', question.id);
            
            // Change button text
            document.querySelector('#addQuestionForm button[onclick="addQuestion()"]').textContent = 'Update Question';
            
            // Show cancel edit button
            document.getElementById('cancelEditBtn').classList.remove('hidden');
            
            // Scroll to form
            document.getElementById('questionText').scrollIntoView({ behavior: 'smooth' });
        }

        function cancelEdit() {
            resetQuizForm();
        }
    </script>
</body>
</html>
