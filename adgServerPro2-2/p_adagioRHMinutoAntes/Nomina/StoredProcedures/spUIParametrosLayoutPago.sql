USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  /****************************************************************************************************     
** Descripción  : Procedimiento para Crear los valores para los Layouts por Empresa    
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2018--8-27    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
***************************************************************************************************/    
    
CREATE PROCEDURE [Nomina].[spUIParametrosLayoutPago] --10 ,1    
(    
	@IDLayoutPago int,    
	@IDUsuario int    
)    
AS    
BEGIN    
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIParametrosLayoutPago]',
		@Tabla		varchar(max) = '[Nomina].[tblLayoutPagoParametros]',
		@Accion		varchar(20)	= 'INSERT'

	insert into Nomina.tblLayoutPagoParametros(IDLayoutPago,IDTipoLayoutParametro)    
	select 
		lp.IDLayoutPago    
		,tlp.IDTipoLayoutParametro   
	from  Nomina.tblCatTiposLayoutParametros tlp   
		inner join Nomina.tblCatTiposLayout tl    
			on tl.IDTipoLayout = tlp.IDTipoLayout   
		inner join Nomina.tblLayoutPago lp   
			on tl.IDTipoLayout = lp.IDTipoLayout   
	where lp.IDLayoutPago = @IDLayoutPago   
		and tlp.IDTipoLayoutParametro not in (select IDLayoutPagoParametros 
												from Nomina.tblLayoutPagoParametros 
												WHERE IDLayoutPago = @IDLayoutPago)  

	SELECT @NewJSON ='['+ STUFF(
            ( select ','+ a.JSON
			from (
				select 
					lp.IDLayoutPago    
					,tlp.IDTipoLayoutParametro   
				from  Nomina.tblCatTiposLayoutParametros tlp   
					inner join Nomina.tblCatTiposLayout tl    
						on tl.IDTipoLayout = tlp.IDTipoLayout   
					inner join Nomina.tblLayoutPago lp   
						on tl.IDTipoLayout = lp.IDTipoLayout   
				where lp.IDLayoutPago = @IDLayoutPago   
				and tlp.IDTipoLayoutParametro not in (select IDLayoutPagoParametros 
												from Nomina.tblLayoutPagoParametros 
												WHERE IDLayoutPago = @IDLayoutPago)  
			) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
								FOR xml path('')
            )
            , 1
            , 1
            , ''
		)
		+']'

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

END
GO
