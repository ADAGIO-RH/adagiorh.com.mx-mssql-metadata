USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblFotosEmpleados](
	[IDEmpleado] [int] NOT NULL,
	[ClaveEmpleado] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_tblFotosEmpleados] PRIMARY KEY CLUSTERED 
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblFotosEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHtblFotosEmpleados_RHtblEmpleadosMaster_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblFotosEmpleados] CHECK CONSTRAINT [FK_RHtblFotosEmpleados_RHtblEmpleadosMaster_IDEmpleado]
GO
