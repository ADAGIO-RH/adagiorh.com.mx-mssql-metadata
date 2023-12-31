USE [p_adagioRHLya]
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
CREATE proc [Norma035].[spIUDenuncia](
		@IDDenuncia int = 0,
		@IDTipoDenuncia int,
        @IDEmpleado int,
        @esAnonima bit,
        @Fecha datetime,
        @Titulo varchar(255),
        @NombreDenunciado varchar(255),
        @Descripción varchar(max),
        @Estatus int
) as


	if (isnull(@IDDenuncia,0) = 0 or @IDDenuncia is null)
	begin
  
		set @IDDenuncia = @@IDENTITY  

		insert into [Norma035].[tblDenuncias](IDTipoDenuncia, IDEmpleado, esAnonima, Fecha , Titulo, NombreDenunciado, Descripcion, Estatus)
		select  @IDTipoDenuncia, @IDEmpleado, @esAnonima, @Fecha   , @Titulo, @NombreDenunciado, @Descripción, @Estatus

	end else
	begin
		update [Norma035].[tblDenuncias]
		set 

			@IDTipoDenuncia = @IDTipoDenuncia, 
			@IDEmpleado = @IDEmpleado, 
			@esAnonima= @esAnonima, 
			@Fecha = @Fecha , 
			@Titulo = @Titulo, 
			@NombreDenunciado = @NombreDenunciado, 
			@Descripción = @Descripción, 
			@Estatus = @Estatus
		where @IDDenuncia = @IDDenuncia	

	end
GO
