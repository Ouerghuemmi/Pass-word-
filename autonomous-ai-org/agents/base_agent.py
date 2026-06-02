"""Base Agent Class - Foundation for all agents"""
from abc import ABC, abstractmethod
from enum import Enum
from typing import Any, Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime
import uuid


class AgentStatus(str, Enum):
    """Agent operational status"""
    INACTIVE = "inactive"
    ACTIVE = "active"
    PAUSED = "paused"
    ERROR = "error"
    RETIRED = "retired"


class AgentRole(str, Enum):
    """Agent role definitions"""
    CEO = "ceo"
    STRATEGY = "strategy"
    MARKET_RESEARCH = "market_research"
    COMPETITOR_INTEL = "competitor_intel"
    PRODUCT_DISCOVERY = "product_discovery"
    DATA_ANALYST = "data_analyst"
    FINANCIAL = "financial"
    PLANNER = "planner"
    SIMULATION = "simulation"
    EXECUTION = "execution"
    VALIDATION = "validation"
    AUDIT = "audit"
    OPTIMIZATION = "optimization"
    SECURITY = "security"
    MEMORY = "memory"


@dataclass
class AgentMessage:
    """Message protocol between agents"""
    id: str
    sender: str
    recipient: str
    message_type: str
    priority: str
    payload: Dict[str, Any]
    timestamp: datetime
    ttl_seconds: int = 3600
    requires_ack: bool = True

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "sender": self.sender,
            "recipient": self.recipient,
            "message_type": self.message_type,
            "priority": self.priority,
            "payload": self.payload,
            "timestamp": self.timestamp.isoformat(),
            "ttl_seconds": self.ttl_seconds,
            "requires_ack": self.requires_ack,
        }


class BaseAgent(ABC):
    """Base class for all autonomous agents"""

    def __init__(
        self,
        name: str,
        role: AgentRole,
        version: str = "1.0.0",
        capabilities: Optional[List[str]] = None,
        config: Optional[Dict[str, Any]] = None,
    ):
        self.id = str(uuid.uuid4())
        self.name = name
        self.role = role
        self.version = version
        self.capabilities = capabilities or []
        self.config = config or {}
        self.status = AgentStatus.INACTIVE
        self.performance_score = 0.0
        self.health_status = "unknown"
        self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        self.last_active_at: Optional[datetime] = None
        self.tasks_completed = 0
        self.tasks_failed = 0
        self.total_execution_time_ms = 0
        self.local_memory: Dict[str, Any] = {}
        self.message_history: List[AgentMessage] = []

    @abstractmethod
    async def execute(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a task"""
        pass

    @abstractmethod
    async def process_message(self, message: AgentMessage) -> AgentMessage:
        """Process incoming message"""
        pass

    async def activate(self) -> None:
        """Activate the agent"""
        self.status = AgentStatus.ACTIVE
        self.updated_at = datetime.utcnow()

    async def deactivate(self) -> None:
        """Deactivate the agent"""
        self.status = AgentStatus.INACTIVE
        self.updated_at = datetime.utcnow()

    def record_success(self, execution_time_ms: int) -> None:
        """Record successful task execution"""
        self.tasks_completed += 1
        self.total_execution_time_ms += execution_time_ms
        self.last_active_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        self._update_performance_score()

    def record_failure(self) -> None:
        """Record failed task execution"""
        self.tasks_failed += 1
        self.last_active_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        self._update_performance_score()

    def _update_performance_score(self) -> None:
        """Update performance score based on success/failure ratio"""
        total_tasks = self.tasks_completed + self.tasks_failed
        if total_tasks > 0:
            success_rate = self.tasks_completed / total_tasks
            self.performance_score = success_rate * 100.0
        else:
            self.performance_score = 100.0

    def get_status_report(self) -> Dict[str, Any]:
        """Get comprehensive agent status report"""
        avg_execution_time = (
            self.total_execution_time_ms / self.tasks_completed
            if self.tasks_completed > 0
            else 0
        )
        return {
            "id": self.id,
            "name": self.name,
            "role": self.role.value,
            "status": self.status.value,
            "performance_score": self.performance_score,
            "tasks_completed": self.tasks_completed,
            "tasks_failed": self.tasks_failed,
            "avg_execution_time_ms": avg_execution_time,
        }
