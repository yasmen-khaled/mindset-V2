package routers

import (
	"mind-set/internal/controller/student"
	"mind-set/internal/middleware"
	"mind-set/ws"
	
	"github.com/gin-gonic/gin"
)

func SetWebStudentRoute(r *gin.Engine) {
	r.GET("/web_student", middleware.AuthStudentAccessHandler(), ws.NewStudentServer)

	v1 := r.Group("webstudent/")
	{

		loginC := student.NewLoginController() // for login and related actions
		 // for levels and related actions

		// Public routes
		v1.POST("login", loginC.Login)
		v1.POST("register", loginC.Register)
		v1.POST("upload_file", loginC.UploadFile)
		v1.POST("send_code", loginC.SendCode)
		v1.POST("forget_password", loginC.ForgetPassword)

		// Protected routes
		v1.POST("get_profile", middleware.AuthStudentAccessHandler(), loginC.GetProfile)
		v1.POST("update_password", middleware.AuthStudentAccessHandler(), loginC.UpdatePassword)
		v1.POST("bind_fcmtoken", middleware.AuthStudentAccessHandler(), loginC.UpdateUserFcmToken)

		v1.POST("update_preferences", middleware.AuthStudentAccessHandler(), loginC.UpdatePreferences)


		v1.GET("levels", middleware.AuthStudentAccessHandler(), loginC.GetStudentLevels)
		v1.GET("topics", middleware.AuthStudentAccessHandler(), loginC.GetTopicsByLevel)
		v1.GET("lessons", middleware.AuthStudentAccessHandler(), loginC.GetLessonsByTopic)  

		v1.POST("buy_skin", middleware.AuthStudentAccessHandler(), loginC.BuySkin)
		v1.POST("activate_skin", middleware.AuthStudentAccessHandler(), loginC.ActivateSkin)

		v1.GET("leaderboard", middleware.AuthStudentAccessHandler(), loginC.GetLeaderboard)

		v1.POST("send_message", middleware.AuthStudentAccessHandler(), loginC.SendMessage)
		v1.GET("chat_messages", middleware.AuthStudentAccessHandler(), loginC.GetChatMessages)


		v1.POST("/exam/submit", middleware.AuthStudentAccessHandler(), loginC.SubmitExam)
		v1.GET("exam/questions", middleware.AuthStudentAccessHandler(), loginC.GetExamQuestions)

		
		v1.POST("/exam/save_repo_url", middleware.AuthStudentAccessHandler(), loginC.SaveRepoURL)
		v1.POST("/exam/code/submit", middleware.AuthStudentAccessHandler(), loginC.SubmitCodeExam)

		v1.PUT("/tasks/:taskId/complete",  middleware.AuthStudentAccessHandler(), loginC.MarkTaskCompleted)

        v1.POST("buy_hearts", middleware.AuthStudentAccessHandler(), loginC.BuyHearts)
		v1.POST("reward", middleware.AuthStudentAccessHandler(), loginC.AddStars)

		
		v1.POST("/update_profile", middleware.AuthStudentAccessHandler(), loginC.UpdateProfile)

	}
}
