USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Saludoc].[tblProcesosEncuestasClienteResultados](
	[IDProcesoEncuesta] [int] NOT NULL,
	[IDEmpleado] [int] NULL,
	[ImporteBase] [decimal](18, 2) NULL,
	[ImporteHamilton] [decimal](18, 2) NULL,
	[ImporteBeck] [decimal](18, 2) NULL,
	[ImporteSuseso] [decimal](18, 2) NULL,
	[ImporteTotal] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteResultados]  WITH CHECK ADD  CONSTRAINT [FK_SaludoctblProcesosEncuestasCliente_SaludoctblProcesosEncuestasClienteResultados_IDProcesoEncuesta] FOREIGN KEY([IDProcesoEncuesta])
REFERENCES [Saludoc].[tblProcesosEncuestasCliente] ([IDProcesoEncuesta])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteResultados] CHECK CONSTRAINT [FK_SaludoctblProcesosEncuestasCliente_SaludoctblProcesosEncuestasClienteResultados_IDProcesoEncuesta]
GO
