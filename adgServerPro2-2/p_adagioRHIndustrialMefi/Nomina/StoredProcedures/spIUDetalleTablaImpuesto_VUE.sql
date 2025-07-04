USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [Nomina].[spIUDetalleTablaImpuesto_VUE] (
     @IDTablaImpuesto int
    ,@LimiteInferior DECIMAL (18,4)
    ,@LimiteSuperior DECIMAL (18,4)
    ,@CoutaFija DECIMAL (18,4)
    ,@Porcentaje DECIMAL (18,4)
	,@IDUsuario int
) as
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max)

	
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

    insert into [Nomina].[tblDetalleTablasImpuestos](IDTablaImpuesto,LimiteInferior,LimiteSuperior,CoutaFija,Porcentaje) 
    values (@IDTablaImpuesto,@LimiteInferior,@LimiteSuperior,@CoutaFija,@Porcentaje)


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

	-- EXEC [Auditoria].[spIAuditoria]
	-- 	@IDUsuario		= @IDUsuario
	-- 	,@Tabla			= @Tabla
	-- 	,@Procedimiento	= @NombreSP
	-- 	,@Accion		= @Accion
	-- 	,@NewData		= @NewJSON
	-- 	,@OldData		= @OldJSON

    select *
    from [Nomina].[tblDetalleTablasImpuestos]
    where IDTablaImpuesto = @IDTablaImpuesto;
END;
GO
