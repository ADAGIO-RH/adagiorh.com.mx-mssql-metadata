USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Schedule.spUISchedule
(
	@IDSchedule int = 0
	,@Nombre Varchar(255)
	,@StoreProcedure Varchar(250)
	,@interval int
	,@active bit =  1
	,@IDTipoAccion int
	,@IDUsuario int
)
AS
BEGIN
	set @Nombre = UPPER(@Nombre)
	IF(isnull(@IDSchedule,0) = 0 )
	BEGIN
		INSERT INTO [Schedule].[tblSchedule](Nombre
											,StoreProcedure
											,interval
											,active
											,IDTipoAccion)
		Values(@Nombre
				,@StoreProcedure
				,@interval
				,@active
				,@IDTipoAccion)
		set @IDSchedule = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE [Schedule].[tblSchedule]
		set Nombre			=  @Nombre			
			,StoreProcedure	=  @StoreProcedure	
			,interval		=  @interval		
			,active			=  @active			
			,IDTipoAccion	=  @IDTipoAccion	
		WHERE IDSchedule = @IDSchedule


	END

	EXEC Schedule.spBuscarSchedule @IDSchedule = @IDSchedule
END
GO
