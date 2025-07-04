USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheets]
(
	@IDUsuario int,
	@DetallePeriodoCaptura [Nomina].[dtDetallePeriodoCaptura] READONLY
)
AS
BEGIN
	declare 
		@IDPeriodo int
	;
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUICapturaDetallePeriodoSheets]',
		@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodo]',
		@Accion		varchar(20)		= 'IMPORTAR CAPTURAS',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;
	select top 1 @IDPeriodo = IDPeriodo from @DetallePeriodoCaptura

	select @NewJSON = a.JSON
	from Nomina.tblCatPeriodos b with (nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDPeriodo,b.ClavePeriodo,b.Descripcion  For XML Raw)) ) a
	where IDPeriodo = @IDPeriodo

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	MERGE Nomina.tblDetallePeriodo AS TARGET
		USING @DetallePeriodoCaptura AS SOURCE
			ON (TARGET.IDConcepto = SOURCE.IDConcepto 
			and TARGET.IDEmpleado = SOURCE.IDEmpleado
			and TARGET.IDPeriodo = SOURCE.IDPeriodo)
	WHEN MATCHED Then
		update
			Set 				
				TARGET.CantidadMonto  = Case when Source.TipoCaptura = 'CantidadMonto' then Source.Value else 0 end
				,TARGET.CantidadDias   = Case when Source.TipoCaptura = 'CantidadDias' then Source.Value else 0 end
				,TARGET.CantidadVeces  = Case when Source.TipoCaptura = 'CantidadVeces' then Source.Value else 0 end
				,TARGET.CantidadOtro1  = Case when Source.TipoCaptura = 'CantidadOtro1' then Source.Value else 0 end
				,TARGET.CantidadOtro2  = Case when Source.TipoCaptura = 'CantidadOtro2' then Source.Value else 0 end
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2)
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto
			,case when Source.TipoCaptura = 'CantidadMonto' then isnull(SOURCE.Value,0) else 0 end
			,case when Source.TipoCaptura = 'CantidadDias'  then isnull(SOURCE.Value,0) else 0 end
			,case when Source.TipoCaptura = 'CantidadVeces' then isnull(SOURCE.Value,0) else 0 end
			,case when Source.TipoCaptura = 'CantidadOtro1' then isnull(SOURCE.Value,0) else 0 end
			,case when Source.TipoCaptura = 'CantidadOtro2' then isnull(SOURCE.Value,0) else 0 end
			);
	

END
GO
