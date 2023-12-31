USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar / Actualizar Encuestas de Norma035
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-06-17
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE proc [Norma035].[spIUMensajeDenuncia](
		@IDMensajeDenuncia int = 0,
		@IDDenuncia int,
        @IDEmpleado int,
        @Texto varchar(max)
) as

	if (isnull(@IDMensajeDenuncia,0) = 0 or @IDMensajeDenuncia is null)
	begin
		set @IDMensajeDenuncia = @@IDENTITY  

		insert into [Norma035].[tblMensajesDenuncia]    ([IDDenuncia] ,[IDEmpleado] ,[FechaHora] ,Texto)
		select @IDDenuncia , @IDEmpleado ,GETDATE() , @Texto 

	end else
	begin
		UPDATE [Norma035].[tblMensajesDenuncia]
		   SET [IDDenuncia] = @IDDenuncia
			  ,[IDEmpleado] = @IDEmpleado
			  ,[FechaHora] = GETDATE()
			  ,@Texto = Texto
		 WHERE IDMensajeDenuncia = @IDMensajeDenuncia

	end
GO
