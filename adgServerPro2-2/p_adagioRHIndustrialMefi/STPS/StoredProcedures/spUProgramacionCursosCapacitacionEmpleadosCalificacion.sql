USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE PROCEDURE [STPS].[spUProgramacionCursosCapacitacionEmpleadosCalificacion]    
(      
	@IDEmpleado int,      
	@IDProgramacionCursoCapacitacion int,      
	@Calificacion varchar(20) = null,      
	@IDUsuario int      
)      
AS      
BEGIN      
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spUProgramacionCursosCapacitacionEmpleadosCalificacion]',
		@Tabla		varchar(max) = '[STPS].[tblProgramacionCursosCapacitacionEmpleados]',
		@Accion		varchar(20)	= 'UPDATE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @OldJSON = a.JSON 
	from (
		select 
			 pcce.IDProgramacionCursosCapacitacionEmpleados
			,pcce.IDProgramacionCursoCapacitacion
			,e.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Colaborador
			,cc.Codigo+' '+cc.Nombre as CursoCapacitacion
			,isnull(pcce.Fecha,getdate()) as Fecha
			,isnull(pcce.IDEstatusCursoEmpleados,0) as IDEstatusCursoEmpleados
			,isnull(ece.Descripcion,'SIN ESTATUS') as EstatusCursoEmpleado
			,pcce.Calificacion
		from STPS.tblProgramacionCursosCapacitacionEmpleados pcce with (nolock)
			join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on pcc.IDProgramacionCursoCapacitacion = pcce.IDProgramacionCursoCapacitacion
			join STPS.tblCursosCapacitacion cc with (nolock) on cc.IDCursoCapacitacion = pcc.IDCursoCapacitacion
			join RH.tblempleadosMaster e with (nolock) on e.IDEmpleado = pcce.IDEmpleado
			left join STPS.tblEstatusCursosEmpleados ece with (nolock) on ece.IDEstatusCursoEmpleados = pcce.IDEstatusCursoEmpleados
		where pcce.IDProgramacionCursosCapacitacionEmpleados = @IDProgramacionCursoCapacitacion
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	UPDATE STPS.tblProgramacionCursosCapacitacionEmpleados 
		set Calificacion = case when isnull(@Calificacion,'') = '' then null else UPPER(@Calificacion) End
	where IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion    
    and IDEmpleado = @IDEmpleado

	select @NewJSON = a.JSON 
	from (
		select 
			 pcce.IDProgramacionCursosCapacitacionEmpleados
			,pcce.IDProgramacionCursoCapacitacion
			,e.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Colaborador
			,cc.Codigo+' '+cc.Nombre as CursoCapacitacion
			,isnull(pcce.Fecha,getdate()) as Fecha
			,isnull(pcce.IDEstatusCursoEmpleados,0) as IDEstatusCursoEmpleados
			,isnull(ece.Descripcion,'SIN ESTATUS') as EstatusCursoEmpleado
			,pcce.Calificacion
		from STPS.tblProgramacionCursosCapacitacionEmpleados pcce with (nolock)
			join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on pcc.IDProgramacionCursoCapacitacion = pcce.IDProgramacionCursoCapacitacion
			join STPS.tblCursosCapacitacion cc with (nolock) on cc.IDCursoCapacitacion = pcc.IDCursoCapacitacion
			join RH.tblempleadosMaster e with (nolock) on e.IDEmpleado = pcce.IDEmpleado
			left join STPS.tblEstatusCursosEmpleados ece with (nolock) on ece.IDEstatusCursoEmpleados = pcce.IDEstatusCursoEmpleados
		where pcce.IDProgramacionCursosCapacitacionEmpleados = @IDProgramacionCursoCapacitacion
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

END;
GO
