USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Guarda y actualiza tareas
** Autor			: Jose Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 


	Si cambia el result set de este sp será necesario actualizar los siguientes SP's:
		-[Evaluacion360].[spGuardarFechasYCalendarizacionProyecto]
		
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE  PROCEDURE [Scheduler].[spUITask]
(
	@IDTask int = 0
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
	IF(isnull(@IDTask,0) = 0 )
	BEGIN
		INSERT INTO [Scheduler].[tblTask](Nombre
											,StoreProcedure
											,interval
											,active
											,IDTipoAccion)
		Values(@Nombre
				,@StoreProcedure
				,@interval
				,@active
				,@IDTipoAccion)
		set @IDTask = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE [Scheduler].[tblTask]
		set Nombre			=  @Nombre			
			,StoreProcedure	=  @StoreProcedure	
			,interval		=  @interval		
			,active			=  @active			
			,IDTipoAccion	=  @IDTipoAccion	
		WHERE IDTask = @IDTask


	END

	EXEC [Scheduler].[spBuscarTasks] @IDTask = @IDTask
END
GO
