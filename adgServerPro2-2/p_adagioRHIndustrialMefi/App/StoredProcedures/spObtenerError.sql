USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spObtenerError]( 
	@IDUsuario int = 0,    
	@CodigoError Varchar(7) = '',    
	@CustomMessage varchar(100) = null    
)
AS    
BEGIN    
     
	DECLARE 
		@Message varchar(max),    
		@IDIdioma Varchar(5)   
	 ;  
   
	Select top 1 @IDIdioma = dp.Valor    
	from Seguridad.tblUsuarios u with (nolock)    
		Inner join App.tblPreferencias p with (nolock)    
			on u.IDPreferencia = p.IDPreferencia    
		Inner join App.tblDetallePreferencias dp with (nolock)    
			on dp.IDPreferencia = p.IDPreferencia    
		Inner join App.tblCatTiposPreferencias tp with (nolock)    
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia    
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'    
     
	 set @IDIdioma = isnull(@IDIdioma,'es-MX')
	select top 1 @Message = e.Descripcion    
	from App.tblCatErrores E with (nolock)    
	where (e.Codigo = @CodigoError) and ((e.IDIdioma = @IDIdioma) or (@IDIdioma is null))    
	--select @Message    
    
	set @Message = coalesce(@Message,'') +' '+coalesce(@CustomMessage,'');    
	raiserror(@Message,16,1);    
END
GO
