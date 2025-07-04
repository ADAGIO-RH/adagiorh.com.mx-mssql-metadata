USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spIUGrupoFiltrosLector](
	 @IDGrupoFiltrosLector int = 0	
	,@IDLector int			
	,@Nombre varchar(255)	
	,@IDUsuarioCreo int		
) as

	if (ISNULL(@IDGrupoFiltrosLector,0) = 0)
	begin
		insert Asistencia.tblGrupoFiltrosLector(IDLector,Nombre,IDUsuarioCreo)
		values (@IDLector,@Nombre,@IDUsuarioCreo)

		set @IDGrupoFiltrosLector = @@IDENTITY
	end else
	begin
		update Asistencia.tblGrupoFiltrosLector
			set Nombre = @Nombre
		where IDGrupoFiltrosLector = @IDGrupoFiltrosLector
	end;

	exec [Asistencia].[spBuscarGrupoFiltrosLector] @IDGrupoFiltrosLector = @IDGrupoFiltrosLector, @IDLector = @IDLector
GO
