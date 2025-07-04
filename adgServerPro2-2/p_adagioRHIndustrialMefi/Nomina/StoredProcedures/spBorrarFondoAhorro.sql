USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBorrarFondoAhorro](
	@IDFondoAhorro int
	,@IDUsuario int
) as
	
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarFondoAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblCatFondosAhorro]',
		@Accion		varchar(20)	= 'DELETE'	
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @OldJSON = a.JSON 
	from (
		select 
			 cfa.IDFondoAhorro
			,c.IDCliente
			,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
			,cfa.IDTipoNomina
			,tn.Descripcion as TipoNomina
			,cfa.Ejercicio
			,cfa.IDPeriodoInicial
			,p.Descripcion as PeriodoInicial
			,isnull(cfa.IDPeriodoFinal,0) as IDPeriodoFinal
			,isnull(pp.Descripcion,'SIN ASIGNAR') as PeriodoFinal
			,isnull(cfa.IDPeriodoPago,0) IDPeriodoPago
			,isnull(ppago.Descripcion,'SIN ASIGNAR') as PeriodoDePago
			,isnull(ppago.Cerrado,cast(0 as bit)) as Pagado
			,isnull(cfa.FechaHora,getdate()) as FechaHora
			,cfa.IDUsuario
			,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
		from Nomina.tblCatFondosAhorro cfa with(nolock)
			join Nomina.tblCatTipoNomina tn with(nolock)		on cfa.IDTipoNomina = tn.IDTipoNomina
			join RH.tblCatClientes c with(nolock)				on tn.IDCliente = c.IDCliente
			join Nomina.tblCatPeriodos p with(nolock)			on cfa.IDPeriodoInicial = p.IDPeriodo
			left join Nomina.tblCatPeriodos pp with(nolock)		on cfa.IDPeriodoFinal = pp.IDPeriodo
			left join Nomina.tblCatPeriodos ppago with(nolock)	on cfa.IDPeriodoPago = ppago.IDPeriodo
			join Seguridad.tblUsuarios u  with(nolock)			on cfa.IDUsuario = u.IDUsuario
		where (cfa.IDFondoAhorro = @IDFondoAhorro)
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a	

	if exists (select top 1 1
				from [Nomina].tblCatFondosAhorro cfa with (nolock)
					join Nomina.tblCatPeriodos ppago with (nolock) on cfa.IDPeriodoPago = ppago.IDPeriodo 
				where cfa.IDFondoAhorro = @IDFondoAhorro and ppago.Cerrado = 1)
	begin
		exec App.spObtenerError @IDUsuario=@IDUsuario,@CodigoError='0410004'
		return;
	end;

	delete 
	from [Nomina].tblCatFondosAhorro
	where IDFondoAhorro = @IDFondoAhorro 

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
