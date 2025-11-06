<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;
protected $fillable = [
    'name',
    'image',
    'level',
    'options',
    'status',
    'order_num',
    'description',
    'stars'
];



    protected $casts = [
        'options' => 'array',
        'status' => 'boolean'
    ];

    public function tasks()
    {
        return $this->hasMany(Task::class);
    }

    public function questions()
    {
        return $this->hasMany(Question::class);
    }
}
