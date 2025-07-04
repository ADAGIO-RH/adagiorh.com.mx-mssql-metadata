USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [Saludoc].[spDatosProcesoEncuestaCliente](
    @IDProcesoEncuesta int = 3,
    @IDUsuario int = 0
)
as
BEGIN

Select 
peccd.IDEmpleado,
m.NOMBRECOMPLETO,
m.RFC,
m.CURP,
m.Sexo,
Datediff(year,m.FechaNacimiento,GETDATE()) as Edad,
'Herreria y contruccion AS CA de CV' as Empresa,
'Avenida Juarez # 173 Colonia centro CP 27000 Ahualulco de Mercado Jalisco' as Direccion,
cc.IDCatCuestionario,
cc.Descripcion as Cuestionario,
[pcc].[Elemento],
[pcc].[Categoria],
[pcc].[Pregunta],
[pcc].[Orden],
[peccd].[Respuesta],
ced.Valor,
ced.Descripcion as DescripcionEscala,
ced.Orden as OrdenEscala
from saludoc.tblProcesosEncuestasClienteCuestionariosDetalle peccd
inner join Saludoc.TblCatPreguntasCuestionario pcc on pcc.IDCatPregunta = peccd.IDCatPregunta
inner join saludoc.TblCatEscalasDetalle ced on ced.IDCatEscala = pcc.IDCatEscala
inner join saludoc.TblCatCuestionarios cc on cc.IDCatCuestionario = peccd.IDCatCuestionario
inner join rh.tblEmpleadosMaster m on peccd.IDEmpleado = m.IDEmpleado
where peccd.IDProcesoEncuesta = @IDProcesoEncuesta 

END
GO
