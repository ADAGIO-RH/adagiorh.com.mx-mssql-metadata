USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spBKLectoresZK]
(
	@IDLector int			= null,
	@IDEmpleado int			= null,
	@Checada datetime		= null,
	@FechaHora datetime		= null
)
AS
BEGIN
	if not exists(select top 1 1 
				from Asistencia.tblBkLectoresZK with (nolock) 
				where IDEmpleado = @IDEmpleado and Checada = @Checada ) 
	begin
		insert into Asistencia.tblBkLectoresZK
		select @IDLector,@IDEmpleado,@Checada,@FechaHora
	end
END
GO
