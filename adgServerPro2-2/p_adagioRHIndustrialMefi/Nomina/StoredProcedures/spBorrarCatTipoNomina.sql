USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [Nomina].[spBorrarCatTipoNomina]  
(  
 @IDTipoNomina int 
 ,@IDUsuario int 
)  
AS  
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarCatTipoNomina]',
		@Tabla		varchar(max) = '[Nomina].[tblCatTipoNomina]',
		@Accion		varchar(20) = 'DELETE'
		,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	EXEC [Nomina].[spBuscarCatTipoNomina]
		@IDUsuario  = @IDUsuario   
		,@IDTipoNomina  = @IDTipoNomina  

	select @OldJSON = a.JSON 
	from (
			Select   
			tp.IDTipoNomina,  
			tp.Descripcion,  
			tp.IDPeriodicidadPago,  
			upper(p.Descripcion) as PerioricidadPago,  
			isnull(tp.IDPeriodo,0) as IDPeriodo,  
			p.ClavePeriodo,  
			ISNULL(C.IDCliente,0) as IDCliente,  
			JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,  
			ISNULL(Pais.IDPais,0) as IDPais,
			Pais.Descripcion as Pais,
			ISNULL(tp.Asimilados,0) as Asimilados

		from Nomina.tblCatTipoNomina tp with (nolock)  
			inner join Sat.tblCatPeriodicidadesPago pp with (nolock)  
				on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago  
			left join Nomina.tblCatPeriodos p with (nolock)   
				on tp.IDPeriodo = p.IDPeriodo  
			Left Join RH.tblCatClientes c with (nolock)  
				on tp.IDCliente = c.IDCliente  
			left join SAT.tblCatPaises Pais with (nolock)
			on Pais.IDPais = tp.IDPais
		where (tp.IDTipoNomina = @IDTipoNomina)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

    BEGIN TRY  
		Delete Nomina.tblCatTipoNomina  
		where IDTipoNomina = @IDTipoNomina 

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON

		EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
			 @IDFiltrosUsuarios		= 0  
			 ,@IDUsuario			= @IDUsuario   
			 ,@Filtro				= 'TiposNomina'  
			 ,@ID					= @IDTipoNomina   
			 ,@Descripcion			= ''
			 ,@IDUsuarioLogin		= @IDUsuario 
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;
END
GO
