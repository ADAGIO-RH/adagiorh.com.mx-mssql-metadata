USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Nomina].[spIUDetalleTablaImpuesto] (
     @IDTablaImpuesto int
    ,@detalle [Nomina].[dtDetalleTablasImpuestos] READONLY
	,@IDUsuario int
) as
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUDetalleTablaImpuesto]',
		@Tabla		varchar(max) = '[Nomina].[tblDetalleTablasImpuestos]',
		@Accion		varchar(20)	= 'INSERT'
	
	SELECT @OldJSON ='['+ STUFF(
            ( select ','+ a.JSON
				from [Nomina].[tblDetalleTablasImpuestos] b
					Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
				where b.IDTablaImpuesto = @IDTablaImpuesto
				FOR xml path('')
            )
            , 1
            , 1
            , '')
			+']'

    delete from [Nomina].[tblDetalleTablasImpuestos]
    where IDTablaImpuesto = @IDTablaImpuesto;
    
    insert into [Nomina].[tblDetalleTablasImpuestos](IDTablaImpuesto,LimiteInferior,LimiteSuperior,CoutaFija,Porcentaje) 
    select @IDTablaImpuesto,LimiteInferior,LimiteSuperior,CoutaFija,Porcentaje
    from @detalle
    where LimiteInferior is not null

	SELECT @NewJSON ='['+ STUFF(
            ( select ','+ a.JSON
				from [Nomina].[tblDetalleTablasImpuestos] b
					Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
				where b.IDTablaImpuesto = @IDTablaImpuesto
				FOR xml path('')
            )
            , 1
            , 1
            , '')
			+']'

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

    select *
    from [Nomina].[tblDetalleTablasImpuestos]
    where IDTablaImpuesto = @IDTablaImpuesto;
END;
GO
