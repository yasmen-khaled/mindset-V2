<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'title',
        'description',
        'priority',
   //     'completed',
   'hint',
        'video_url',
        'image',
        'stars',
        'order_num',
        'avatar'
    ];

 /*   protected $casts = [
        'completed' => 'boolean'
    ];
*/
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
} 